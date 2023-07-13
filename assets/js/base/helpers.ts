const baseHelpers = {
  alpineExpressionIsObject(expression: string): boolean {
    /** If expression can be evaluated as an object, return true. */
    // expression begins and ends with curly braces
    return expression.substring(0, 1) === "{" && expression.slice(-1) === "}";
  },

  stringCapitalize(val: string) {
    return val ? val[0].toUpperCase() + val.slice(1) : "";
  },
};

export default baseHelpers;
