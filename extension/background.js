var originalLog = console.log;

var globalEval = eval;

chrome.extension.onConnect.addListener(function (port) {
    port.onMessage.addListener(function (message, info) {
        console.log = function (s) {
            originalLog.apply(console, [s]);
            port.postMessage({ log: s });
        };

        try {
            var obj = globalEval(message);
            port.postMessage({ success: obj });
        } catch (e) {
            port.postMessage({ error: e });
        }
    })
});
