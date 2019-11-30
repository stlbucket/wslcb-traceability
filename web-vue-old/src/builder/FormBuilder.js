export class FormBuilder {
  constructor (h) {
    this.h = h
    this.fields = []
  }

  setFields(fields) {
    this.fields.push(
      fields.map(f => {
        return this.formInput(
          this.h("input", {
            class: {
              input: true
            },
            domProps: {
              type: f.type || "text",
              placeholder: f.name,
              name: f.name
            }
          })
        )
      })
    )
  }

  setSubmit(text) {
    this.fields.push(
      this.formButton[
        this.h("input", {
          class: "button is-link",
          domProps: { type: "submit", value: text }
        }),
        { value: text }
      ]
    )
  }
}