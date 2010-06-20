# ChromeRepl

ChromeRepl provides remote read-eval-print-loop to Google Chrome and Chromium.
It's similar like MozRepl.
Please try with <http://gemcutter.org/gems/google-chrome-client>.

## How To Use

 1. Install the extension (or "server") from
    <https://chrome.google.com/extensions/>.
 2. Install the client library from
    <http://gemcutter.org/gems/google-chrome-client>.
 3. Launch Google Chrome (or Chromium) with --remote-shell-port option.

        % google-chrome --remote-shell-port=9222

 4. Launch chrome-repl command.

        % chrome-repl
        Protocol version: 0.1
        > 1 + 2
        3
        > chrome.tabs
        {"onAttached"=>{"eventName_"=>"tabs.onAttached", "listeners_"=>[]},
         "onCreated"=>{"eventName_"=>"tabs.onCreated", "listeners_"=>[]},
         "onDetached"=>{"eventName_"=>"tabs.onDetached", "listeners_"=>[]},
         "onMoved"=>{"eventName_"=>"tabs.onMoved", "listeners_"=>[]},
         "onRemoved"=>{"eventName_"=>"tabs.onRemoved", "listeners_"=>[]},
         "onSelectionChanged"=>
          {"eventName_"=>"tabs.onSelectionChanged", "listeners_"=>[]},
         "onUpdated"=>{"eventName_"=>"tabs.onUpdated", "listeners_"=>[]}}
        > 

