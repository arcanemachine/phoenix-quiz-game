// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin");
const fs = require("fs");
const path = require("path");

module.exports = {
  content: ["./js/**/*.js", "../lib/*_web.ex", "../lib/*_web/**/*.*ex"],
  daisyui: {
    logs: false,
    themes: [
      {
        light: {
          primary: "#0255D2",
          secondary: "#51575E",
          accent: "#3830C5",
          neutral: "#325993",
          "base-100": "#F8FCFA",
          info: "#9CD4FF",
          success: "#136941",
          warning: "#FFC107",
          error: "#B82030",
        },
        dark: {
          primary: "#589AFD",
          secondary: "#51575E",
          accent: "#4529A9",
          neutral: "#325993",
          "base-100": "#051E12",
          info: "#A4C2EF",
          success: "#136941",
          warning: "#FFC107",
          error: "#E15462",
        },
      },
    ],
  },
  theme: {
    extend: {
      colors: {
        brand: "#003B4A",
      },
    },
  },
  safelist: [
    "alert-info",
    "alert-success",
    "alert-warning",
    "alert-error",
    "bg-primary",
    "bg-secondary",
    "bg-accent",
    "bg-neutral",
    "bg-info",
    "bg-success",
    "bg-warning",
    "bg-error",
    "btn-primary",
    "btn-secondary",
    "btn-accent",
    "btn-neutral",
    "btn-info",
    "btn-success",
    "btn-warning",
    "btn-error",
    "text-primary-content",
    "text-secondary-content",
    "text-accent-content",
    "text-neutral-content",
    "text-info-content",
    "text-success-content",
    "text-error-content",
    "text-warning-content",
  ],
  plugins: [
    // require("@tailwindcss/forms"),
    require("@tailwindcss/typography"),
    plugin(({ addVariant }) =>
      addVariant("phx-no-feedback", [
        ".phx-no-feedback&",
        ".phx-no-feedback &",
      ]),
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-click-loading", [
        ".phx-click-loading&",
        ".phx-click-loading &",
      ]),
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-submit-loading", [
        ".phx-submit-loading&",
        ".phx-submit-loading &",
      ]),
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-change-loading", [
        ".phx-change-loading&",
        ".phx-change-loading &",
      ]),
    ),
    // heroicons
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "./vendor/heroicons/optimized");
      let values = {};
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
      ];
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).map((file) => {
          let name = path.basename(file, ".svg") + suffix;
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) };
        });
      });
      matchComponents(
        {
          hero: ({ name, fullPath }) => {
            let content = fs
              .readFileSync(fullPath)
              .toString()
              .replace(/\r?\n|\r/g, "");
            return {
              [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
              "-webkit-mask": `var(--hero-${name})`,
              mask: `var(--hero-${name})`,
              "mask-repeat": "no-repeat",
              "background-color": "currentColor",
              "vertical-align": "middle",
              display: "inline-block",
              width: theme("spacing.5"),
              height: theme("spacing.5"),
            };
          },
        },
        { values },
      );
    }),
    require("daisyui"),
  ],
};
