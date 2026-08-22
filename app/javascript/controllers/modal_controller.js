import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  /**
   * モーダルを開く。
   * リンクのデフォルト遷移を止め、turbo-frame#modal の src に URL を設定する。
   */
  open(event) {
    event.preventDefault() // linkの遷移を止める
    const url = event.currentTarget.dataset.url // 開きたいURLを取得
    const frame = document.getElementById("modal") // layoutに置くturbo-frame
    if (frame) frame.src = url // Turboで内容を読み込む
  }

  /**
   * モーダル内リンクの遷移（詳細→編集など）。
   * data-turbo-frame だけでは Frame 差し替え後にリンクが効かなくなるため、
   * frame.src を直接更新してページ遷移せずモーダル内で差し替える。
   */
  navigate(event) {
    event.preventDefault()
    const url = event.currentTarget.href
    if (!url) return

    const frame = this.element.closest("turbo-frame")
    if (frame) frame.src = url
  }

  /**
   * モーダルを閉じる。
   * turbo-frame#modal の中身を空にしてオーバーレイを消す。
   */
  close() {
    // モーダル全体を取得
    const frame = this.element.closest("turbo-frame")
    // モーダル全体の中身を空にする
    if (frame) frame.innerHTML = ""
  }

  /**
   * モーダル本体クリック時に背景への click 伝播を止める。
   * コンテンツ領域のクリックでモーダルが閉じないようにする。
   */
  stop(event) {
    event.stopPropagation()
  }
}
