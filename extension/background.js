chrome.extension.onConnect.addListener(function (port) {
    port.onMessage.addListener(function (message, info) {
        try {
            var obj = eval(message);
            port.postMessage({ success: obj });
        } catch (e) {
            port.postMessage({ error: e });
        }
    })
});
