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

export const data = [
  {
    name: "themeSelect",
    data: themeSelect,
  },
];

/* directives */
export const directives = [];

/* stores */
export const stores = [{ name: "helpers", store: helpers }];
