import { AlpineComponent } from "alpinejs";
import Toastify from "toastify-js";
import tippy from "tippy.js";

import helpers from "js/helpers";

/* data */
function themeSelect() {
  return {
    themeOptions: ["Auto", "Light", "Dark"],
    theme: helpers.base.stringCapitalize(
      // this value must be capitalized so that x-model works as expected
      localStorage.getItem("theme") || "auto"
    ),

    handleChange() {
      const theme = this.theme.toLowerCase();

      if (theme !== "auto") {
        // set theme and saved preference
        document.documentElement.dataset.theme = theme;
        localStorage.setItem("theme", theme);
      } else {
        // clear theme and saved preference
        document.documentElement.removeAttribute("data-theme");
        localStorage.removeItem("theme");
      }
    },
  };
}

function toastContainer(): AlpineComponent {
  return {
    bindings: {
      "@clear": "$store.toasts.clear",
      "@phx:toast-show.window": "(evt) => $store.toasts.show(evt.detail)",
      "@phx:toast-show-primary.window":
        "(evt) => $store.toasts.showPrimary(evt.detail)",
      "@phx:toast-show-secondary.window":
        "(evt) => $store.toasts.showSecondary(evt.detail)",
      "@phx:toast-show-accent.window":
        "(evt) => $store.toasts.showAccent(evt.detail)",
      "@phx:toast-show-neutral.window":
        "(evt) => $store.toasts.showNeutral(evt.detail)",
      "@phx:toast-show-info.window":
        "(evt) => $store.toasts.showInfo(evt.detail)",
      "@phx:toast-show-success.window":
        "(evt) => $store.toasts.showSuccess(evt.detail)",
      "@phx:toast-show-warning.window":
        "(evt) => $store.toasts.showWarning(evt.detail)",
      "@phx:toast-show-error.window":
        "(evt) => $store.toasts.showError(evt.detail)",
    },

    init() {
      this.$el.setAttribute("x-bind", "bindings");
    },
  };
}

export const data = [
  {
    name: "themeSelect",
    data: themeSelect,
  },
  {
    name: "toastContainer",
    data: toastContainer,
  },
];

/* directives */
export const directives = [
  {
    name: "tooltip",
    directive(
      elt: HTMLElement,
      { expression }: any,
      { evaluate, cleanup }: any
    ) {
      /** Create a tooltip popup. */
      if (!expression) return; // abort if expression is empty

      const defaultOptions = {
        delay: [750, null],
        interactiveDebounce: 150,
        touch: ["hold", 500],
      };

      // parse expression and convert to object
      let options: Record<string, any>;
      if (helpers.base.alpineExpressionIsObject(expression)) {
        options = evaluate(expression); // expression is an object
      } else {
        options = { content: expression }; // convert expression to object
      }

      // finalized options
      options = {
        ...defaultOptions,
        ...options,
      };

      // create tooltip
      const tip = tippy(elt, options);

      // add 'aria-label' attribute to improve accessibility
      elt.setAttribute("aria-label", options.content);

      // when element is removed from the DOM, destroy the tooltip
      cleanup(() => {
        tip.destroy();
      });
    },
  },
];

/* stores */
// toasts
type ProjectToastifyOptions = Toastify.Options & {
  content?: string; // use 'content' instead of 'text' for consistency
  theme?:
    | "primary"
    | "secondary"
    | "accent"
    | "neutral"
    | "info"
    | "success"
    | "warning"
    | "error";
};

const toasts = {
  clear() {
    /** Remove all existing toast messages. */
    document.querySelectorAll(".toastify.on").forEach((toastElt) => {
      toastElt.dispatchEvent(new MouseEvent("click"));
    });
  },
  coerceInputs(
    options: string | ProjectToastifyOptions = {}
  ): ProjectToastifyOptions {
    /** Coerce the value of 'options' based on certain factors:
     *  a. If 'options' is a string, convert it to a basic toast options object.
     *      - e.g. "hello" -> { text: "hello" }
     *  b. If 'options' object contains 'content' key, convert it to a 'text'
     *    key. This maintains consistency with the use of the 'content' key
     *    in other areas of this project (tooltips, etc.).
     *      - e.g. { content: "hello"} -> { text: "hello" }
     */
    if (typeof options === "string") {
      // a. Convert string to basic toast object
      options = { text: options } as ProjectToastifyOptions;
    }

    if (options.content) {
      // b. Remap options.content to options.text
      options.text = options.text ?? options.content;
      delete options.content;
    }

    if (!options.text) throw "options['content'|'text'] must not be empty";

    return options;
  },
  hide(toast: any) {
    /** Hide a toast message. */
    toast.hideToast();
  },
  show(options: string | ProjectToastifyOptions = {}) {
    /** Create a new toast message. */
    let toast: any; // create instance placeholder for use in 'hide' callback

    options = this.coerceInputs(options) as ProjectToastifyOptions;

    // themes
    const theme = options.theme || "primary";
    switch (theme) {
      case "primary":
        options.style = {
          background: "hsl(var(--p))",
          color: "hsl(var(--pc))",
        };
        break;
      case "secondary":
        options.style = {
          background: "hsl(var(--s))",
          color: "hsl(var(--sc))",
        };
        break;
      case "accent":
        options.style = {
          background: "hsl(var(--a))",
          color: "hsl(var(--ac))",
        };
        break;
      case "neutral":
        options.style = {
          background: "hsl(var(--n))",
          color: "hsl(var(--nc))",
        };
        break;
      case "info":
        options.style = {
          background: "hsl(var(--in))",
          color: "hsl(var(--inc))",
        };
        break;
      case "success":
        options.style = {
          background: "hsl(var(--su))",
          color: "hsl(var(--suc))",
        };
        break;
      case "warning":
        options.style = {
          background: "hsl(var(--wa))",
          color: "hsl(var(--wac))",
        };
        break;
      case "error":
        options.style = {
          background: "hsl(var(--er))",
          color: "hsl(var(--erc))",
        };
        break;
      default:
        options.style = {
          background: "hsl(var(--p))",
          color: "hsl(var(--pc))",
        };
    }

    // create text element
    const textElement = document.createElement("span");
    textElement.className = "toast-text";

    if (options.escapeMarkup) {
      textElement.innerText = options.text as string;
    } else {
      textElement.innerHTML = options.text as string;
    }

    // only show 3 toasts at a time
    const existingToasts = document.querySelectorAll(".toastify.on");
    if (existingToasts.length > 2) {
      // remove the last toast
      Array.from(existingToasts)
        .slice(-1)[0]
        .dispatchEvent(new MouseEvent("click"));
    }

    // create toast
    toast = Toastify({
      // text: options.content,
      node: textElement,
      className: `toast-${theme}`,
      close: true,
      duration: 5000,
      gravity: "bottom",
      onClick: () => this.hide(toast),
      selector: document.querySelector("#toast-container"),
      ...options,
    } as ProjectToastifyOptions).showToast();

    return toast;
  },
  showPrimary(options: string | ProjectToastifyOptions = {}) {
    /** Create toast message with "primary" theme. */
    options = this.coerceInputs(options) as ProjectToastifyOptions;
    return this.show({ ...options, theme: "primary" });
  },
  showSecondary(options: string | ProjectToastifyOptions = {}) {
    /** Create toast message with "secondary" theme. */
    options = this.coerceInputs(options) as ProjectToastifyOptions;
    return this.show({ ...options, theme: "secondary" });
  },
  showAccent(options: string | ProjectToastifyOptions = {}) {
    /** Create toast message with "accent" theme. */
    options = this.coerceInputs(options) as ProjectToastifyOptions;
    return this.show({ ...options, theme: "accent" });
  },
  showNeutral(options: string | ProjectToastifyOptions = {}) {
    /** Create toast message with "neutral" theme. */
    options = this.coerceInputs(options) as ProjectToastifyOptions;
    return this.show({ ...options, theme: "neutral" });
  },
  showInfo(options: string | ProjectToastifyOptions = {}) {
    /** Create toast message with "info" theme. */
    options = this.coerceInputs(options) as ProjectToastifyOptions;
    return this.show({ ...options, theme: "info" });
  },
  showSuccess(options: string | ProjectToastifyOptions = {}) {
    /** Create toast message with "success" theme. */
    options = this.coerceInputs(options) as ProjectToastifyOptions;
    return this.show({ ...options, theme: "success" });
  },
  showWarning(options: string | ProjectToastifyOptions = {}) {
    /** Create toast message with "warning" theme. */
    options = this.coerceInputs(options) as ProjectToastifyOptions;
    return this.show({ ...options, theme: "warning" });
  },
  showError(options: string | ProjectToastifyOptions = {}) {
    /** Create toast message with "error" theme. */
    options = this.coerceInputs(options) as ProjectToastifyOptions;
    return this.show({ ...options, theme: "error" });
  },
};

export const stores = [
  { name: "helpers", store: helpers },
  { name: "toasts", store: toasts },
];
