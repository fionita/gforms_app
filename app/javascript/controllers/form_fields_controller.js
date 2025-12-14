import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fields", "template"]

  connect() {
    this.fieldIndex = this.fieldsTarget.children.length
  }

  addField(event) {
    event.preventDefault()
    
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.fieldsTarget.insertAdjacentHTML('beforeend', content)
    this.fieldIndex++
    this.updatePositions()
  }

  removeField(event) {
    event.preventDefault()
    
    const field = event.target.closest('.field-group')
    
    // If this is a persisted field, mark it for destruction
    const destroyInput = field.querySelector('input[name*="_destroy"]')
    if (destroyInput) {
      destroyInput.value = '1'
      field.style.display = 'none'
    } else {
      field.remove()
    }
    
    this.updatePositions()
  }

  toggleOptions(event) {
    const fieldGroup = event.target.closest('.field-group')
    const optionsContainer = fieldGroup.querySelector('.options-container')
    
    if (event.target.value === 'select') {
      optionsContainer.classList.remove('hidden')
    } else {
      optionsContainer.classList.add('hidden')
    }
  }

  updatePositions() {
    const visibleFields = Array.from(this.fieldsTarget.querySelectorAll('.field-group')).filter(
      field => field.style.display !== 'none'
    )
    
    visibleFields.forEach((field, index) => {
      const positionInput = field.querySelector('input[name*="position"]')
      if (positionInput) {
        positionInput.value = index
      }
    })
  }
}
