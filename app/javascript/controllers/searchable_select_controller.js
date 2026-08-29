import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

// 出演情報フォームなどの<select>を検索可能なドロップダウンにする
export default class extends Controller {
  // allowEmpty: 空の<option>を選択肢として残すか（ステージの「未定」など）
  // placeholder: 未選択時に表示するプレースホルダー
  static values = {
    allowEmpty: { type: Boolean, default: true },
    placeholder: { type: String, default: "" }
  }

  connect() {
    if (this.element.tomselect) return

    this.select = new TomSelect(this.element, {
      allowEmptyOption: this.allowEmptyValue,
      placeholder: this.placeholderValue || undefined,
      create: false,
      maxOptions: null,
      sortField: { field: "text", direction: "asc" },
      render: {
        no_results: () => '<div class="no-results">該当する項目がありません</div>'
      }
    })
  }

  disconnect() {
    if (this.select) {
      this.select.destroy()
      this.select = null
    }
  }
}
