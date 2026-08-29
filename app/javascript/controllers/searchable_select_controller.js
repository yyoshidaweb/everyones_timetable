import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

/**
 * 出演情報フォームなどのselectを検索可能なドロップダウンにする。
 * allowEmpty: 空のoptionを選択肢として残すか（ステージの「未定」など）
 * placeholder: 未選択時に表示するプレースホルダー
 */
export default class extends Controller {
  static values = {
    allowEmpty: { type: Boolean, default: true },
    placeholder: { type: String, default: "" }
  }

  /**
   * 要素にTom Selectを初期化する。
   * 既に初期化済みの場合は何もしない。
   */
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

  /**
   * Tom Selectインスタンスを破棄してDOMを元に戻す。
   */
  disconnect() {
    if (this.select) {
      this.select.destroy()
      this.select = null
    }
  }
}
