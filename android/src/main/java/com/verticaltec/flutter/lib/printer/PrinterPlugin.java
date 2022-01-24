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

import com.izettle.html2bitmap.Html2Bitmap;
import com.izettle.html2bitmap.content.WebViewContent;
import com.rt.printerlibrary.bean.WiFiConfigBean;
import com.rt.printerlibrary.cmd.Cmd;
import com.rt.printerlibrary.cmd.EscFactory;
import com.rt.printerlibrary.connect.PrinterInterface;
import com.rt.printerlibrary.enumerate.BmpPrintMode;
import com.rt.printerlibrary.enumerate.CommonEnum;
import com.rt.printerlibrary.enumerate.ConnectStateEnum;
import com.rt.printerlibrary.enumerate.SpeedEnum;
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

    private Context mContext;
    private MethodChannel mChannel;

    private CountDownLatch mPrinterSignal;
    private PrinterFactory mPrinterFactory;
    private RTPrinter mRtPrinter;
    private boolean mIsConnected;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        mContext = flutterPluginBinding.getApplicationContext();

        BinaryMessenger messenger = flutterPluginBinding.getBinaryMessenger();
        BinaryMessenger.TaskQueue taskQueue = messenger.makeBackgroundTaskQueue();

        mChannel = new MethodChannel(messenger, "printer", StandardMethodCodec.INSTANCE, taskQueue);
        mChannel.setMethodCallHandler(this);

        initPrinter();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "printBill":
                printBill(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Log.d(TAG, "onDetachedFromEngine");
        releasePrinter();
        mChannel.setMethodCallHandler(null);
    }

    private void initPrinter() {
        mPrinterSignal = new CountDownLatch(1);
        mPrinterFactory = new UniversalPrinterFactory();
        mRtPrinter = mPrinterFactory.create();

        PrinterObserverManager.getInstance().add(mPrinterObserver);
    }

    private PrinterObserver mPrinterObserver = new PrinterObserver() {
        @Override
        public void printerObserverCallback(PrinterInterface printerInterface, int state) {
            if (state == CommonEnum.CONNECT_STATE_SUCCESS) {
                mIsConnected = true;
                Log.d(TAG, "Connected");
            }else{
                mIsConnected = false;
                Log.d(TAG, "Not connect");
            }
            mPrinterSignal.countDown();
        }

        @Override
        public void printerReadMsgCallback(PrinterInterface printerInterface, byte[] bytes) {
        }
    };

    private void releasePrinter(){
        try{
            mRtPrinter.disConnect();
        }catch (Exception e){
            e.printStackTrace();
        }finally {
            PrinterObserverManager.getInstance().remove(mPrinterObserver);
        }
        Log.d(TAG, "release printer");
    }

    private void printBill(MethodCall call, Result result) {
        final String printerName = call.argument("printerName");
        final int tcpPort = call.argument("tcpPort");
        final String content = call.argument("content");
        final int scale = call.argument("scale");
        final int bitmapWidth = call.argument("bitmapWidth");

        try {
            WiFiConfigBean wiFiConfigBean = new WiFiConfigBean(printerName, tcpPort);
            PIFactory piFactory = new WiFiFactory();
            PrinterInterface printerInterface = piFactory.create();
            printerInterface.setConfigObject(wiFiConfigBean);
            mRtPrinter.setPrinterInterface(printerInterface);

            try {
                mRtPrinter.connect(wiFiConfigBean);
                Log.d(TAG, "Before await");
                mPrinterSignal.await(); // wait for connection signal
                Log.d(TAG, "After await");

                if(!mIsConnected){
                    result.error("99", "Can't connect to printer!", null);
                    return;
                }

                Html2Bitmap build = new Html2Bitmap.Builder()
                        .setContext(mContext)
                        .setContent(WebViewContent.html(content))
                        .setStrictMode(true)
                        .setTextZoom(scale)
                        .setBitmapWidth(bitmapWidth)
                        .build();
                Bitmap b = build.getBitmap();

                CmdFactory escFac = new EscFactory();
                Cmd escCmd = escFac.create();
                escCmd.append(escCmd.getHeaderCmd());

                CommonSetting commonSetting = new CommonSetting();
                commonSetting.setAlign(CommonEnum.ALIGN_MIDDLE);
                escCmd.append(escCmd.getCommonSettingCmd(commonSetting));

                BitmapSetting bitmapSetting = new BitmapSetting();
                bitmapSetting.setBmpPrintMode(BmpPrintMode.MODE_SINGLE_COLOR);
                try {
                    escCmd.append(escCmd.getBitmapCmd(bitmapSetting, b));
                } catch (SdkException e) {
                    Log.e(TAG, "Set bitmap error: " + e.getMessage());
                    result.error("99", "Set bitmap error: " + e.getMessage(), null);
                } finally {
                    b.recycle();
                }
                escCmd.append(escCmd.getLFCRCmd());
                escCmd.append(escCmd.getLFCRCmd());
                escCmd.append(escCmd.getLFCRCmd());
                escCmd.append(escCmd.getLFCRCmd());
                escCmd.append(escCmd.getLFCRCmd());
                escCmd.append(escCmd.getAllCutCmd());

                mRtPrinter.writeMsg(escCmd.getAppendCmds());
                result.success("Print success");
            } catch (Exception e) {
                Log.e(TAG, "Error: " + e.getMessage());
                result.error("99", e.getMessage(), null);
            }
        } catch (Exception e) {
            Log.e(TAG, "Error: " + e.getMessage());
            result.error("99", e.getMessage(), null);
        }
    }
}
