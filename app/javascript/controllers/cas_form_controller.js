import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["level", "default_checkbox"]
  check_using_roles() {
    const master_checked = event.currentTarget.checked
    for(var i = 0; i < this.default_checkboxTargets.length; i++){
      this.default_checkboxTargets[i].checked = false;
    };
    event.currentTarget.checked = master_checked;
    for(var i = 0; i < this.levelTargets.length; i++){
      if (this.levelTargets[i].className.includes(event.currentTarget.id)) {
        this.levelTargets[i].checked = event.currentTarget.checked;
      }
    }
  }
}
