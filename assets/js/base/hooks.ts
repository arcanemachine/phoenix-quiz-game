import { Hook, makeHook } from "phoenix_typed_hook";

class SimpleFormHook extends Hook {
  /**
   * If a form has been modified and the user is attempting to exit the page,
   * then show a warning before exiting the page. This is intended to prevent
   * the form data from being lost during unintentional navigation before the
   * form has been submitted.
   *
   * TODO
   *   - add 'data-confirm' attribute to all other links when shouldWarnOnExit()
   *     evaluates to true, and remove the attribute when it evaluates to false
   */

  initialFormFieldItems: Record<string, string> = {};
  modifiedFormFields: Set<string> = new Set();
  warnOnExit() {
    return this.el.dataset.warnOnExit;
  }
  shouldWarnOnExit() {
    return (
      this.warnOnExit() === "always" ||
      (this.warnOnExit() === "change" && this.modifiedFormFields.size)
    );
  }

  // lifecycle
  mounted(): void {
    this.initialFormFieldItems = {};
    this.modifiedFormFields = new Set();

    // maybe disable form modification detection
    if (
      // via component param
      this.warnOnExit() === "never" ||
      // via localStorage attribute (useful during development)
      localStorage.getItem("debug:formDetectModifications") === "false"
    )
      return;

    // bind event listeners locally
    this.handleInput = this.handleInput.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleBeforeUnload = this.handleBeforeUnload.bind(this);

    // add event listeners related to form modification detection
    addEventListener("input", this.handleInput);
    addEventListener("submit", this.handleSubmit);

    // always bind the 'beforeunload' listener if warnOnExit is set to "always"
    if (this.warnOnExit() === "always") {
      addEventListener("beforeunload", this.handleBeforeUnload);
    }

    this.initialFormFieldItems = this.getInitialFormFields();
  }

  updated(): void {
    // add and remove fields client-side as they are added to/removed from the
    // form on the server side
    const currentFormFieldElements = this.getFormFieldElements();

    // check if any fields have been added
    for (const currentFormFieldElement of currentFormFieldElements) {
      const currentFormFieldName = currentFormFieldElement.name;

      // if new field is not present in the list of initial fields, then add
      // its initial value now
      if (
        !Object.keys(this.initialFormFieldItems).includes(currentFormFieldName)
      )
        this.initialFormFieldItems[currentFormFieldName] = this.getInputValue(
          currentFormFieldElement,
        );
    }

    // check if any fields have been removed
    const oldFormFieldNames = Object.keys(this.initialFormFieldItems);

    for (const oldFormFieldName of oldFormFieldNames) {
      const currentFormFieldNames = Array.from(this.getFormFieldElements()).map(
        (formFieldElt) => formFieldElt.getAttribute("name"),
      ) as Array<string>;

      // if form field is no longer present in the form, then remove it from the
      // list of initialFormFieldItems and modifiedFormFields
      if (!currentFormFieldNames.includes(oldFormFieldName)) {
        delete this.initialFormFieldItems[oldFormFieldName];
        this.modifiedFormFields.delete(oldFormFieldName);
      }
    }

    if (this.shouldWarnOnExit()) {
      // allow inspection of form status outside of this hook
      this.el.setAttribute("data-form-has-modified-inputs", "true");

      // show warning when exiting the page
      addEventListener("beforeunload", this.handleBeforeUnload);
    } else {
      // allow inspection of form status outside of this hook
      this.el.removeAttribute("data-form-has-modified-inputs");

      // remove warning when exiting the page
      removeEventListener("beforeunload", this.handleBeforeUnload);
    }
  }

  destroyed(): void {
    this.modifiedFormFields.clear(); // clear modified input fields

    // remove event listeners related to form modification detection
    removeEventListener("input", this.handleInput);
    removeEventListener("submit", this.handleSubmit);
    removeEventListener("beforeunload", this.handleBeforeUnload);
  }

  // helpers
  getFormFieldElements(): NodeListOf<HTMLFormElement> {
    /** Return all named elements in the form. */

    return this.el.querySelectorAll(
      "input[name], select[name], textarea[name]",
    );
  }

  getInitialFormFields(): Record<string, string> {
    /** Get initial values for all named elements in the form. */

    const formFieldValues = Object.assign({}, this.initialFormFieldItems);

    this.getFormFieldElements().forEach((elt) => {
      const name = elt.name as keyof typeof this.initialFormFieldItems;

      // only assign the value if it is not already present
      formFieldValues[name] =
        formFieldValues[name] || this.getInputValue(elt as HTMLFormElement);
    });

    return formFieldValues;
  }

  getInputValue(elt: HTMLFormElement): string {
    /**
     * Returns the value of an input element based on the input's type (e.g.
     * text, checkbox, textarea).
     */

    if (elt.type === "checkbox") return String(elt.checked);
    else if (elt.nodeName === "TEXTAREA") return elt.textContent || "";
    else return elt.value;
  }

  handleInput(evt: Event): void {
    /**
     * Handle client-side detection of form modifications, and add/remove
     * the 'beforeunload' handler accordingly.
     */
    const target = evt.target as HTMLFormElement;

    // ignore elements with no 'name' property (e.g. confirmation checkbox)
    if (!target.name) return;

    // if value has changed, add it to the set of modified elements. otherwise,
    // remove it from the set
    const initialValue = this.initialFormFieldItems[target.name];
    const valueAfterInput = this.getInputValue(target);

    if (initialValue !== valueAfterInput) {
      this.modifiedFormFields.add(target.name);
    } else {
      this.modifiedFormFields.delete(target.name);
    }

    // set event handlers and data attributes based on modified input count
    if (this.shouldWarnOnExit()) {
      // allow inspection of form status outside of this hook
      this.el.setAttribute("data-form-has-modified-inputs", "true");

      // show warning when exiting the page
      addEventListener("beforeunload", this.handleBeforeUnload);
    } else {
      // allow inspection of form status outside of this hook
      this.el.removeAttribute("data-form-has-modified-inputs");

      // remove warning when exiting the page
      removeEventListener("beforeunload", this.handleBeforeUnload);
    }
  }

  handleSubmit(): void {
    /** Clear modified inputs before submitting the form. */
    this.modifiedFormFields.clear();

    // remove 'beforeunload' event listener (improves back/forward caching?)
    removeEventListener("beforeunload", this.handleBeforeUnload);
  }

  handleBeforeUnload(evt: BeforeUnloadEvent): void {
    /**
     * Always warn before exiting. This event handler will be attached under
     * the following circumstances:
     *   - warnOnExit is set to "always"
     *   - or, warnOnExit is set to "change" and the form has unsaved changes
     */
    evt.returnValue = true;
  }
}

class ModalHook extends Hook {
  mounted() {
    this.handlePhxHide = this.handlePhxHide.bind(this); // bind event listeners locally
    this.el.addEventListener("phx:hide", this.handlePhxHide); // add event listeners
  }

  destroyed() {
    this.el.removeEventListener("phx:hide", this.handlePhxHide); // remove event listeners
  }

  handlePhxHide() {
    /**
     * Before closing the modal, check if the modal has a form with modified
     * elements. If such a form exists, prompt the user before closing the
     * modal.
     */

    let modalWillBeHidden = false;

    if (this.el.querySelector("[data-form-has-modified-inputs='true']")) {
      modalWillBeHidden = confirm(
        "This form has unsaved changes. Are you sure you want to exit the form?",
      );
    } else {
      modalWillBeHidden = true;
    }

    if (modalWillBeHidden) {
      // @ts-expect-error
      this.liveSocket.execJS(this.el, this.el.dataset.phxHide);
    }
  }
}

const Hooks = {
  SimpleForm: makeHook(SimpleFormHook),
  Modal: makeHook(ModalHook),
};

export default Hooks;
