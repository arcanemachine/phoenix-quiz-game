const baseHelpers = {
  stringCapitalize(val: string) {
    return val ? val[0].toUpperCase() + val.slice(1) : "";
  },
};

export default baseHelpers;
