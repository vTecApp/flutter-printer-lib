package com.verticaltec.flutter.lib.printer;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.net.nsd.NsdManager;
import android.net.nsd.NsdServiceInfo;
import android.util.Log;
import android.webkit.WebView;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.izettle.html2bitmap.Html2Bitmap;
import com.izettle.html2bitmap.Html2BitmapConfigurator;
import com.izettle.html2bitmap.content.WebViewContent;
import com.rt.printerlibrary.bean.WiFiConfigBean;
import com.rt.printerlibrary.cmd.Cmd;
import com.rt.printerlibrary.cmd.EscFactory;
import com.rt.printerlibrary.connect.PrinterInterface;
import com.rt.printerlibrary.enumerate.BmpPrintMode;
import com.rt.printerlibrary.enumerate.CommonEnum;
import com.rt.printerlibrary.enumerate.ConnectStateEnum;
import com.rt.printerlibrary.enumerate.ESCFontTypeEnum;
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
import com.rt.printerlibrary.setting.CommonSetting;
import com.rt.printerlibrary.setting.TextSetting;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
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
    private static final String TAG = PrinterPlugin.class.getName();

    private Context mContext;
    private MethodChannel mChannel;
    private Result mResult;

    private NsdManager mNsdManager;

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
            Html2Bitmap build = new Html2Bitmap.Builder()
                    .setContext(mContext)
                    .setContent(WebViewContent.html(content))
                    .setStrictMode(true)
                    .build();

            Bitmap b = build.getBitmap();

            WiFiConfigBean wiFiConfigBean = new WiFiConfigBean(printerName, tcpPort);
            PIFactory piFactory = new WiFiFactory();
            PrinterInterface printerInterface = piFactory.create();
            printerInterface.setConfigObject(wiFiConfigBean);
            mRtPrinter.setPrinterInterface(printerInterface);
            try {
                mRtPrinter.connect(wiFiConfigBean);
                mPrinterSignal.await(); // wait for connection signal

                Log.d(TAG, mRtPrinter.getConnectState().toString());

                CmdFactory escFac = new EscFactory();
                Cmd escCmd = escFac.create();
                escCmd.append(escCmd.getHeaderCmd());

                int widthLimit = b.getWidth();
                if (widthLimit > 72)
                    widthLimit = 72;
                BitmapSetting bitmapSetting = new BitmapSetting();
                bitmapSetting.setBmpPrintMode(BmpPrintMode.MODE_SINGLE_COLOR);
                bitmapSetting.setBimtapLimitWidth(widthLimit * 8);

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
                Log.e(TAG, e.getMessage());
            } finally {
                mRtPrinter.disConnect();
            }
        } catch (Exception e) {
            Log.e(TAG, e.getMessage());
        }
    }
}
