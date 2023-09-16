import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

import Alpine from "alpinejs";
import collapse from "@alpinejs/collapse";
import focus from "@alpinejs/focus";
import topbar from "../vendor/topbar";

import Hooks from "./hooks";

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

Alpine.plugin(collapse);
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
      // enable Alpine.js support
      if (from._x_dataStack) {
        window.Alpine.clone(from, to);
      }

      // do not update 'data-js' attributes
      for (const attr of from.attributes) {
        if (attr.name.startsWith("data-js-")) {
          to.setAttribute(attr.name, attr.value);
        }
      }
    },
  },
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
});

// show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect to any liveviews on the page
liveSocket.connect();

// expose livesocket on window for debugging
window.liveSocket = liveSocket;
