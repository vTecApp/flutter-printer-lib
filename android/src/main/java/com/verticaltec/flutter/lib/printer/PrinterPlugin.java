package com.verticaltec.flutter.lib.printer;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.PaintFlagsDrawFilter;
import android.net.nsd.NsdManager;
import android.net.nsd.NsdServiceInfo;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import com.rt.printerlibrary.bean.WiFiConfigBean;
import com.rt.printerlibrary.cmd.Cmd;
import com.rt.printerlibrary.cmd.EscFactory;
import com.rt.printerlibrary.connect.PrinterInterface;
import com.rt.printerlibrary.enumerate.BmpPrintMode;
import com.rt.printerlibrary.enumerate.CommonEnum;
import com.rt.printerlibrary.exception.SdkException;
import com.rt.printerlibrary.factory.cmd.CmdFactory;
import com.rt.printerlibrary.factory.connect.PIFactory;
import com.rt.printerlibrary.factory.connect.WiFiFactory;
import com.rt.printerlibrary.factory.printer.PrinterFactory;
import com.rt.printerlibrary.factory.printer.UniversalPrinterFactory;
import com.rt.printerlibrary.observer.PrinterObserver;
import com.rt.printerlibrary.observer.PrinterObserverManager;
import com.rt.printerlibrary.printer.RTPrinter;
import com.rt.printerlibrary.setting.BitmapSetting;

import java.io.ByteArrayOutputStream;
import java.io.FileOutputStream;
import java.util.concurrent.CountDownLatch;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.StandardMethodCodec;

/**
 * PrinterPlugin
 */
public class PrinterPlugin implements FlutterPlugin, MethodCallHandler {
    private static final String TAG = "PrinterPlugin";

    private static final int MSG_START_RENDER_HTML = 101;
    private static final int MSG_END_RENDER_HTML = 102;

    private Context mContext;
    private MethodChannel mChannel;
    private Result mResult;

    private NsdManager mNsdManager;

    private HandlerThread mHandlerThread;
    private Handler mBackgroundHandler;
    private Handler mHandler;
    private WebView mWebView;

    private CountDownLatch mPrinterSignal;
    private PrinterFactory mPrinterFactory;
    private RTPrinter mRtPrinter;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        mContext = flutterPluginBinding.getApplicationContext();

        BinaryMessenger messenger = flutterPluginBinding.getBinaryMessenger();
        BinaryMessenger.TaskQueue taskQueue = messenger.makeBackgroundTaskQueue();

        mChannel = new MethodChannel(messenger, "printer", StandardMethodCodec.INSTANCE, taskQueue);
        mChannel.setMethodCallHandler(this);

        initHandler();
        initWebView();
        initNsd();
        initPrinter();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        mResult = result;
        switch (call.method) {
            case "printBill":
                printBill(call);
                break;
            case "discoverPrinter":
                discoverPrinter();
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        mChannel.setMethodCallHandler(null);
    }

    private void initHandler() {
        mHandlerThread = new HandlerThread("print_handler");
        mHandlerThread.start();

        mBackgroundHandler = new Handler(mHandlerThread.getLooper()) {
            @RequiresApi(api = Build.VERSION_CODES.N)
            @Override
            public void handleMessage(@NonNull Message msg) {
                switch (msg.what) {
                    case MSG_END_RENDER_HTML:
                        byte[] byteArray = msg.getData().getByteArray("img");
                        Bitmap b = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.length);
                        try {
//                            String path = mContext.getDataDir().toString() + "/pic.png";
//                            FileOutputStream out = new FileOutputStream(path);
//                            Log.d(TAG, "Path: " + path);
//                            b.compress(Bitmap.CompressFormat.PNG, 100, out);
//                            out.flush();
//                            out.close();
//                            b.recycle();

                            CmdFactory escFac = new EscFactory();
                            Cmd escCmd = escFac.create();
                            escCmd.append(escCmd.getHeaderCmd());

                            BitmapSetting bitmapSetting = new BitmapSetting();
                            bitmapSetting.setBmpPrintMode(BmpPrintMode.MODE_MULTI_COLOR);

                            try {
                                escCmd.append(escCmd.getBitmapCmd(bitmapSetting, b));
                            } catch (SdkException e) {
                                e.printStackTrace();
                            }

                            escCmd.append(escCmd.getLFCRCmd());
                            escCmd.append(escCmd.getLFCRCmd());
                            escCmd.append(escCmd.getLFCRCmd());
                            escCmd.append(escCmd.getLFCRCmd());
                            escCmd.append(escCmd.getLFCRCmd());
                            escCmd.append(escCmd.getAllCutCmd());

                            mRtPrinter.writeMsg(escCmd.getAppendCmds());
                            mResult.success("Print success");
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        finally {
                            mRtPrinter.disConnect();
                        }
                        break;
                }
            }
        };

        mHandler = new Handler(Looper.getMainLooper()) {
            @Override
            public void handleMessage(@NonNull Message msg) {
                switch (msg.what) {
                    case MSG_START_RENDER_HTML:
                        String content = msg.getData().getString("content");
                        mWebView.loadData(content, "text/html", "utf-8");
                        break;
                }
            }
        };
    }


    private void initWebView() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            WebView.enableSlowWholeDocumentDraw();
        }
        mWebView = new WebView(mContext);
        mWebView.setInitialScale(100);
        mWebView.setVerticalScrollBarEnabled(false);

        final WebSettings settings = mWebView.getSettings();
        settings.setBuiltInZoomControls(false);
        settings.setSupportZoom(false);
        settings.setTextZoom(150);

        int widthMeasureSpec = View.MeasureSpec.makeMeasureSpec(480, View.MeasureSpec.EXACTLY);
        int heightMeasureSpec = View.MeasureSpec.makeMeasureSpec(10, View.MeasureSpec.EXACTLY);
        mWebView.measure(widthMeasureSpec, heightMeasureSpec);
        mWebView.layout(0, 0, mWebView.getMeasuredWidth(), mWebView.getMeasuredHeight());

        mWebView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                int widthMeasureSpec = View.MeasureSpec.makeMeasureSpec(480, View.MeasureSpec.EXACTLY);
                int heightMeasureSpec = View.MeasureSpec.makeMeasureSpec(view.getContentHeight(), View.MeasureSpec.EXACTLY);

                view.measure(widthMeasureSpec, heightMeasureSpec);
                view.layout(0, 0, view.getMeasuredWidth(), view.getMeasuredHeight());

                Log.d(TAG, "webView width: " + view.getMeasuredWidth());
                Log.d(TAG, "webView height:" + view.getMeasuredHeight());

                if (view.getMeasuredWidth() <= 0 || view.getMeasuredHeight() <= 0) {
                    Log.e(TAG, "Can't draw bitmap because content width or height <= 0");
                    return;
                }

                Bitmap b = Bitmap.createBitmap(view.getMeasuredWidth(),
                        view.getMeasuredHeight(), Bitmap.Config.RGB_565);

                Canvas canvas = new Canvas(b);
                view.draw(canvas);
                canvas.setDrawFilter(new PaintFlagsDrawFilter(Paint.ANTI_ALIAS_FLAG, 0));

                Log.d(TAG, "width="
                        + canvas.getWidth());
                Log.d(TAG, "height="
                        + canvas.getHeight());

                if (b != null) {

                    ByteArrayOutputStream stream = new ByteArrayOutputStream();
                    b.compress(Bitmap.CompressFormat.PNG, 100, stream);
                    byte[] byteArray = stream.toByteArray();

                    Message msg = new Message();
                    msg.what = MSG_END_RENDER_HTML;
                    Bundle bundle = new Bundle();
                    bundle.putByteArray("img", byteArray);
                    msg.setData(bundle);
                    mBackgroundHandler.sendMessage(msg);
                }
            }
        });
    }

    private void initNsd() {
        mNsdManager = (NsdManager) mContext.getSystemService(Context.NSD_SERVICE);
    }

    private void initPrinter() {
        mPrinterSignal = new CountDownLatch(1);
        mPrinterFactory = new UniversalPrinterFactory();
        mRtPrinter = mPrinterFactory.create();

        PrinterObserverManager.getInstance().add(new PrinterObserver() {
            @Override
            public void printerObserverCallback(PrinterInterface printerInterface, int state) {
                if (state == CommonEnum.CONNECT_STATE_SUCCESS) {
                    Log.d(TAG, "Connected");
                }
                mPrinterSignal.countDown();
            }

            @Override
            public void printerReadMsgCallback(PrinterInterface printerInterface, byte[] bytes) {
            }
        });
    }

    private void discoverPrinter() {
        mNsdManager.discoverServices("_ipp._tcp", NsdManager.PROTOCOL_DNS_SD, new NsdManager.DiscoveryListener() {
            @Override
            public void onStartDiscoveryFailed(String s, int i) {
                Log.d(TAG, "Start discovery failed " + s);
            }

            @Override
            public void onStopDiscoveryFailed(String s, int i) {
                Log.d(TAG, "Stop discovery failed");
            }

            @Override
            public void onDiscoveryStarted(String s) {
                Log.d(TAG, "Discovery started");
            }

            @Override
            public void onDiscoveryStopped(String s) {
                Log.d(TAG, "Discovery stopped");
            }

            @Override
            public void onServiceFound(NsdServiceInfo nsdServiceInfo) {
                Log.d(TAG, "Service Found!!! " + nsdServiceInfo.getServiceName());
            }

            @Override
            public void onServiceLost(NsdServiceInfo nsdServiceInfo) {
                Log.d(TAG, "Service lost");
            }
        });
    }

    private void printBill(MethodCall call) {
        final String printerName = call.argument("printerName");
        final int tcpPort = call.argument("tcpPort");
        final String content = call.argument("content");

        try {
            WiFiConfigBean wiFiConfigBean = new WiFiConfigBean(printerName, tcpPort);
            PIFactory piFactory = new WiFiFactory();
            PrinterInterface printerInterface = piFactory.create();
            printerInterface.setConfigObject(wiFiConfigBean);
            mRtPrinter.setPrinterInterface(printerInterface);

            mRtPrinter.connect(wiFiConfigBean);
            mPrinterSignal.await(); // wait for connection signal

            Bundle bundle = new Bundle();
            bundle.putString("content", content);
            Message msg = new Message();
            msg.what = MSG_START_RENDER_HTML;
            msg.setData(bundle);
            mHandler.sendMessage(msg);

//            new Handler(Looper.getMainLooper()).post(() -> {
//                mWebView.loadData(content, "text/html", "utf-8");
//            });

//            Html2Bitmap build = new Html2Bitmap.Builder()
//                    .setContext(mContext)
//                    .setContent(WebViewContent.html(content))
//                    .setStrictMode(true)
//                    .build();
//
//            Bitmap b = build.getBitmap();
//
//            WiFiConfigBean wiFiConfigBean = new WiFiConfigBean(printerName, tcpPort);
//            PIFactory piFactory = new WiFiFactory();
//            PrinterInterface printerInterface = piFactory.create();
//            printerInterface.setConfigObject(wiFiConfigBean);
//            mRtPrinter.setPrinterInterface(printerInterface);
//            try {
//                mRtPrinter.connect(wiFiConfigBean);
//                mPrinterSignal.await(); // wait for connection signal
//
//                Log.d(TAG, mRtPrinter.getConnectState().toString());
//
//                CmdFactory escFac = new EscFactory();
//                Cmd escCmd = escFac.create();
//                escCmd.append(escCmd.getHeaderCmd());
//
//                int widthLimit = b.getWidth();
//                if (widthLimit > 72)
//                    widthLimit = 72;
//                BitmapSetting bitmapSetting = new BitmapSetting();
//                bitmapSetting.setBmpPrintMode(BmpPrintMode.MODE_SINGLE_COLOR);
//                bitmapSetting.setBimtapLimitWidth(widthLimit * 8);
//
//                try {
//                    escCmd.append(escCmd.getBitmapCmd(bitmapSetting, b));
//                } catch (SdkException e) {
//                    e.printStackTrace();
//                }
//
//                escCmd.append(escCmd.getLFCRCmd());
//                escCmd.append(escCmd.getLFCRCmd());
//                escCmd.append(escCmd.getLFCRCmd());
//                escCmd.append(escCmd.getLFCRCmd());
//                escCmd.append(escCmd.getLFCRCmd());
//                escCmd.append(escCmd.getAllCutCmd());
//
//                mRtPrinter.writeMsg(escCmd.getAppendCmds());
//                mResult.success("Print success");
//            } catch (Exception e) {
//                Log.e(TAG, e.getMessage());
//            } finally {
//                mRtPrinter.disConnect();
//            }
        } catch (Exception e) {
            Log.e(TAG, e.getMessage());
        }
    }
}
