import { AlpineComponent } from "alpinejs";
import Toastify from "toastify-js";
import tippy from "tippy.js";

import helpers from "js/helpers";

/* data */
function simpleForm() {
  /**
   * If a form has been modified and the user is attempting to exit the page,
   * then show a warning before exiting the page. This is intended to prevent
   * the form data from being lost during accidental navigation before the form
   * has been submitted.
   */

  return {
    form: undefined,
    // locals: {}, // local variables that can be set in the form

    // optional confirmation checkbox
    confirmed: false,

    // form modification checker
    defaultValue: "arbitraryDefaultValue",
    modifiedInputs: new Set(),

    init() {
      // // @ts-ignore-error - add object reference to component store
      // this.$store.components.simpleForm = this;

      // maybe disable form modification detection
      if (
        // disable in LiveView modals (automatic)
        this.$root.closest("[data-component-kind='modal']") ||
        // via localStorage attribute (manual)
        localStorage.getItem("formDetectModifications") === "false"
        // // via HTML data attribute (manual)
        // || this.$root.children[0].dataset.formDetectModifications === "false"
      )
        return;

      // add form modification event listeners
      addEventListener("beforeinput", this.handleBeforeInput.bind(this));
      addEventListener("input", this.handleInput.bind(this) as any);
      addEventListener("submit", this.handleSubmit.bind(this));
      addEventListener("beforeunload", this.handleBeforeUnload.bind(this));
    },

    destroy() {
      // // @ts-ignore-error
      // delete this.$store.components.simpleForm;

      // maybe disable form modification detection
      if (
        // disable in LiveView modals (automatic)
        this.$root.closest("[data-component-kind='modal']") ||
        // via localStorage attribute (manual)
        localStorage.getItem("formDetectModifications") === "false"
        // // via HTML data attribute (manual)
        // || this.$root.children[0].dataset.formDetectModifications === "false"
      )
        return;

      // clear modified input fields
      this.modifiedInputs.clear();

      // remove event listeners
      removeEventListener("beforeinput", this.handleBeforeInput);
      removeEventListener("input", this.handleInput as any);
      removeEventListener("submit", this.handleSubmit);
      removeEventListener("beforeunload", this.handleBeforeUnload);
    },

    handleBeforeInput(evt: Event) {
      /** Store default values. */
      const target = evt.target as any;
      if (
        !(this.defaultValue in target || this.defaultValue in target.dataset)
      ) {
        target.dataset[this.defaultValue] = (
          "" + (target.value || target.textContent)
        ).trim();
      }
    },

    handleInput(evt: InputEvent) {
      /** Keep a record of which form inputs have been modified. */
      const target = evt.target as any;

      // ignore elements with no 'name' property (e.g. confirmation checkbox)
      if (!target.name) return;

      let original: string;
      if (this.defaultValue in target) {
        original = target[this.defaultValue];
      } else {
        original = target.dataset[this.defaultValue];
      }

      if (original !== ("" + (target.value || target.textContent)).trim()) {
        if (!this.modifiedInputs.has(target)) {
          this.modifiedInputs.add(target);
        }
      } else if (this.modifiedInputs.has(target)) {
        this.modifiedInputs.delete(target);
      }
    },

    handleSubmit() {
      /** Clear modified inputs before submitting the form. */
      this.modifiedInputs.clear();
    },

    handleBeforeUnload(evt: BeforeUnloadEvent) {
      /** Warn before exiting if any inputs have been modified. */
      if (this.modifiedInputs.size) {
        evt.returnValue = true;
      }
    },
  } as AlpineComponent;
}

function themeSelect() {
  return {
    themeOptions: ["Auto", "Light", "Dark"],

    // this value must be capitalized so that x-model works as expected
    theme: helpers.base.stringCapitalize(
      localStorage.getItem("theme") || "auto",
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

export const data = [
  {
    name: "simpleForm",
    data: simpleForm,
  },
  {
    name: "themeSelect",
    data: themeSelect,
  },
];

/* directives */
export const directives = [
  {
    name: "tooltip",
    directive(
      elt: HTMLElement,
      { expression }: any,
      { evaluate, cleanup }: any,
    ) {
      /**
       * Create a tooltip popup.
       *
       * This directive accepts any one of the following parameters as an
       * expression:
       *   - A string containing a basic tooltip message
       *   - An object with a 'content' key containing the tooltip message, and
       *     any other desired tippy.js props
       */
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
  // use 'content' instead of 'text' to maintain project-level consistency
  content?: string;
};
type ProjectToastifyTheme =
  | "primary"
  | "secondary"
  | "accent"
  | "neutral"
  | "info"
  | "success"
  | "warning"
  | "error";

const toasts = {
  clear() {
    /** Remove all existing toast messages. */
    document.querySelectorAll(".toastify.on").forEach((toastElt) => {
      toastElt.dispatchEvent(new MouseEvent("click"));
    });
  },

  coerceInputs(
    options: string | ProjectToastifyOptions = {},
  ): ProjectToastifyOptions {
    /**
     * Coerce the value of 'options' based on certain factors:
     *
     *  a. If 'options' is a string, convert it to a basic toast options object.
     *    - e.g. "hello" -> { text: "hello" }
     *
     *  b. If 'options' object contains 'content' key, convert it to a 'text'
     *  key. This maintains consistency with the use of the 'content' key
     *  in other areas of this project (tooltips, etc.).
     *    - e.g. { content: "hello"} -> { text: "hello" }
     */
    if (typeof options === "string") {
      // a. Convert string to basic toast object
      options = { text: options } as ProjectToastifyOptions;
    }

    if (options.content) {
      // b. Remap options.content to options.text for project-level consistency
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

  show(
    theme: ProjectToastifyTheme,
    options: string | ProjectToastifyOptions = {},
  ) {
    /** Create a new toast message. */
    let toast: any; // create instance placeholder for use in 'hide' callback

    options = this.coerceInputs(options);

    // themes
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
        throw `Theme must be one of: primary, secondary, accent, neutral, info, success, warning, error`;
    }

    // create text element
    const textElement = document.createElement("span");
    textElement.className = "toast-text";

    if (options.escapeMarkup) {
      textElement.innerText = options.text as string;
    } else {
      textElement.innerHTML = options.text as string;
    }

    // only show 1 toasts at a time
    const existingToasts = document.querySelectorAll(".toastify.on");
    if (existingToasts.length) {
      // remove the last toast
      Array!
        .from(existingToasts)
        .slice(-1)[0]
        .querySelector(".toast-close")!
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
};

export const stores = [
  // { name: "components", store: {} },
  { name: "helpers", store: helpers },
  { name: "toasts", store: toasts },
];
