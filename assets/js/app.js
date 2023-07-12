import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

import Alpine from "alpinejs";
import focus from "@alpinejs/focus";
import topbar from "../vendor/topbar";

// initialize alpinejs
import {
  data as alpineData,
  directives as alpineDirectives,
  stores as alpineStores,
} from "js/alpine";

for (const data of alpineData) {
  Alpine.data(data.name, data.data);
}

for (const directive of alpineDirectives) {
  Alpine.directive(directive.name, directive.directive);
}

for (const store of alpineStores) {
  Alpine.store(store.name, store.store);
}

Alpine.plugin(focus);

Alpine.start();
window.Alpine = Alpine;

// initialize livesocket
let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  dom: {
    onBeforeElUpdated(from, to) {
      const liveSocketInitializeAlpine = (from, to) => {
        if (!Alpine || !from || !to) return;

        for (let index = 0; index < to.children.length; index++) {
          const from2 = from.children[index];
          const to2 = to.children[index];

          if (from2 instanceof HTMLElement && to2 instanceof HTMLElement) {
            liveSocketInitializeAlpine.call(from2, to2);
          }
        }

        if (from._x_dataStack) Alpine.clone(from, to);
      };

      liveSocketInitializeAlpine(from, to);
    },
  },
  params: { _csrf_token: csrfToken },
});

// // add alpine store for livesocket
// Alpine.store("liveSocket", liveSocket);

// show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose livesocket on window for debugging
window.liveSocket = liveSocket;
