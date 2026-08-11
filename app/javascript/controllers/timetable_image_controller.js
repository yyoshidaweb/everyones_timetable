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
      captureRoot = await this.#fetchCaptureRoot(day.date, "offscreen")
      document.body.appendChild(captureRoot)

      let dataUrl = await this.#renderCapture(captureRoot)
      if (await this.#looksBlankCapture(dataUrl)) {
        captureRoot.remove()
        captureRoot = await this.#fetchCaptureRoot(day.date, "onscreen-fallback")
        document.body.appendChild(captureRoot)
        dataUrl = await this.#renderCapture(captureRoot)
      }

      this.showPreview(dataUrl, day)
    } catch (error) {
      console.error(error)
      this.showError("画像の生成に失敗しました。<br>時間をおいて再度お試しください。")
    } finally {
      captureRoot?.remove()
    }
  }

  async #fetchCaptureRoot(date, placement = "offscreen") {
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

    this.#applyPlacementStyle(root, placement)

    return root
  }

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

  #applyPlacementStyle(root, placement) {
    root.style.position = "fixed"
    root.style.top = "0"
    root.style.pointerEvents = "none"

    if (placement === "onscreen-fallback") {
      // 一部ブラウザで画面外配置が白画像化するため、透過表示で再試行する
      root.style.left = "0"
      root.style.opacity = "0.01"
      root.style.zIndex = "-1"
      return
    }

    root.style.left = "-10000px"
    root.style.zIndex = "0"
  }

  async #looksBlankCapture(dataUrl) {
    const image = new Image()
    image.src = dataUrl
    await image.decode()

    const canvas = document.createElement("canvas")
    canvas.width = image.width
    canvas.height = image.height
    const context = canvas.getContext("2d")
    if (!context) return false

    context.drawImage(image, 0, 0)
    const sampleX = Math.max(1, Math.floor(canvas.width / 5))
    const sampleY = Math.max(1, Math.floor(canvas.height / 5))
    const pixels = context.getImageData(0, 0, canvas.width, canvas.height).data

    for (let y = 0; y < canvas.height; y += sampleY) {
      for (let x = 0; x < canvas.width; x += sampleX) {
        const index = (y * canvas.width + x) * 4
        const r = pixels[index]
        const g = pixels[index + 1]
        const b = pixels[index + 2]
        const a = pixels[index + 3]
        if (a > 0 && (r < 245 || g < 245 || b < 245)) {
          return false
        }
      }
    }
    return true
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
