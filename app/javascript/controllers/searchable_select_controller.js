import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

// 出演情報フォームなどの<select>を検索可能なドロップダウンにする
export default class extends Controller {
  connect() {
    if (this.element.tomselect) return

    this.select = new TomSelect(this.element, {
      allowEmptyOption: true,
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
