function randomQuizForm() {
  return {
    count: 10,
    operations: [],
    min: 0,
    max: 10,
    leftConstant: "",

    buildQuizUrl() {
      const params = new URLSearchParams();
      params.set("count", this.count);
      params.set("operations", this.operations.join(","));
      params.set("min", this.min);
      params.set("max", this.max);
      this.leftConstant !== "" &&
        params.set("left_constant", this.leftConstant);

      return `/quizzes/random/take?${params.toString()}`;
    },

    getSelectedOperations() {
      const operations = [];

      // add each selected operation to the array
      this.$root
        .querySelectorAll("input[type='checkbox'][name='operations']")
        .forEach((elt) => {
          if (elt.checked) operations.push(elt.value);
        });

      return operations;
    },

    handleSubmit() {
      // ensure that at least one operation has been selected
      this.operations = this.getSelectedOperations();

      if (!this.operations.length) {
        this.$store.toasts.show(
          "error",
          "To continue, you must select at least one math operation (e.g. 'Add')."
        );

        return;
      }

      // redirect to custom quiz
      location.href = this.buildQuizUrl();
    },
  };
}
