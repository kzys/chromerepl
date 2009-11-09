var originalLog = console.log;

chrome.extension.onConnect.addListener(function (port) {
    port.onMessage.addListener(function (message, info) {
        console.log = function (s) {
            originalLog.apply(console, [s]);
            port.postMessage({ log: s });
        };

        try {
            var obj = eval(message);
            port.postMessage({ success: obj });
        } catch (e) {
            port.postMessage({ error: e });
        }
    })
});
