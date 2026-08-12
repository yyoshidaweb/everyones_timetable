import { Controller } from "@hotwired/stimulus"
import { domToPng } from "modern-screenshot"

// タイムテーブルを画像化してプレビュー・保存する
export default class extends Controller {
  static targets = [
    "shareContent",
    "loadingContent",
    "previewContent",
    "errorContent",
    "errorMessage",
    "previewImage",
    "daySelect",
    "favoriteMarkers"
  ]
  static values = {
    filename: String,
    filenameBase: String,
    captureUrl: String,
    days: { type: Array, default: [] }
  }

  // 「画像を保存」→1日目を画像化してプレビュー表示
  start(event) {
    event.preventDefault()

    if (!this.daysValue.length) {
      this.showError("開催日がありません。")
      return
    }

    this.#generateForDate(this.daysValue[0])
  }

  // プレビュー内のselectで日付変更→その日の画像を再生成
  changeDay(event) {
    const date = event.target.value
    const day = this.#dayByDate(date)
    if (!day) {
      this.showError("選択した日付のタイムテーブルを取得できませんでした。")
      return
    }
    this.#generateForDate(day)
  }

  // お気に入りマーカー表示の切り替え→現在の日付で再生成
  changeFavoriteMarkers() {
    const day = this.#selectedDay()
    if (!day) {
      this.showError("選択した日付のタイムテーブルを取得できませんでした。")
      return
    }
    this.#generateForDate(day)
  }

  // プレビュー画像をダウンロード
  download(event) {
    event.preventDefault()
    if (!this.hasPreviewImageTarget || !this.previewImageTarget.src) return

    const link = document.createElement("a")
    link.href = this.previewImageTarget.src
    link.download = this.filenameValue
    link.click()
  }

  // 共有内容に戻る
  backToShare(event) {
    event.preventDefault()
    this.#showOnly("shareContent")
  }

  showLoading() {
    this.#showOnly("loadingContent")
  }

  showPreview(dataUrl, day) {
    if (this.hasPreviewImageTarget) {
      this.previewImageTarget.src = dataUrl
    }
    if (this.hasDaySelectTarget && day?.date) {
      this.daySelectTarget.value = day.date
    }
    this.#showOnly("previewContent")
  }

  showError(message) {
    if (this.hasErrorMessageTarget && message) {
      this.errorMessageTarget.innerHTML = message
    }
    this.#showOnly("errorContent")
  }

  async #generateForDate(day) {
    this.filenameValue = this.#filenameFor(day.date)
    this.showLoading()

    let captureRoot = null
    try {
      captureRoot = await this.#fetchCaptureRoot(day.date)
      document.body.appendChild(captureRoot)

      const dataUrl = await this.#renderCapture(captureRoot)
      this.showPreview(dataUrl, day)
    } catch (error) {
      console.error(error)
      this.showError("画像の生成に失敗しました。<br>時間をおいて再度お試しください。")
    } finally {
      captureRoot?.remove()
    }
  }

  async #fetchCaptureRoot(date) {
    const url = new URL(this.captureUrlValue, window.location.origin)
    url.searchParams.set("d", date)
    url.searchParams.set("favorites", this.#includeFavoriteMarkers() ? "1" : "0")

    const response = await fetch(url.toString(), {
      headers: { Accept: "text/html" },
      credentials: "same-origin"
    })
    if (!response.ok) {
      throw new Error(`capture request failed: ${response.status}`)
    }

    const html = await response.text()
    const template = document.createElement("template")
    template.innerHTML = html.trim()
    const root = template.content.querySelector("[data-timetable-image-capture-root]")
    if (!root) {
      throw new Error("capture root not found")
    }

    this.#applyOffscreenStyle(root)

    return root
  }

  // フォントと描画の完了を待ってからDOMをPNG化する
  async #renderCapture(captureRoot) {
    if (document.fonts?.ready) {
      await document.fonts.ready
    }
    await new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)))

    return domToPng(captureRoot, {
      scale: 2,
      backgroundColor: "#ffffff"
    })
  }

  // キャプチャ用DOMを画面外に置き、生成中に見えないようにする
  #applyOffscreenStyle(root) {
    root.style.position = "fixed"
    root.style.top = "0"
    root.style.left = "-10000px"
    root.style.pointerEvents = "none"
  }

  #selectedDay() {
    if (this.hasDaySelectTarget) {
      return this.#dayByDate(this.daySelectTarget.value)
    }
    return this.daysValue[0] || null
  }

  #dayByDate(date) {
    return this.daysValue.find((item) => item.date === date) || null
  }

  #includeFavoriteMarkers() {
    return !this.hasFavoriteMarkersTarget || this.favoriteMarkersTarget.checked
  }

  #filenameFor(date) {
    const mmdd = date.slice(5, 7) + date.slice(8, 10)
    return `${this.filenameBaseValue}_${mmdd}.png`
  }

  #showOnly(targetName) {
    const map = {
      shareContent: this.hasShareContentTarget ? this.shareContentTarget : null,
      loadingContent: this.hasLoadingContentTarget ? this.loadingContentTarget : null,
      previewContent: this.hasPreviewContentTarget ? this.previewContentTarget : null,
      errorContent: this.hasErrorContentTarget ? this.errorContentTarget : null
    }

    Object.entries(map).forEach(([name, el]) => {
      if (!el) return
      el.classList.toggle("hidden", name !== targetName)
    })
  }
}
