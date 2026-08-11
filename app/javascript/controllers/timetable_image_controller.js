import { Controller } from "@hotwired/stimulus"
import { toPng } from "html-to-image"

// タイムテーブルを画像化してプレビュー・保存する
export default class extends Controller {
  static targets = [
    "shareContent",
    "loadingContent",
    "previewContent",
    "errorContent",
    "previewImage"
  ]
  static values = {
    filename: String,
    minWidth: { type: Number, default: 1024 },
    stageMinWidth: { type: Number, default: 120 }
  }

  // 「画像を保存」→ローディング→プレビューへ差し替え
  async generate(event) {
    event.preventDefault()
    this.showLoading()

    let captureRoot = null
    try {
      captureRoot = this.#buildCaptureRoot()
      document.body.appendChild(captureRoot)

      if (document.fonts?.ready) {
        await document.fonts.ready
      }
      // レイアウト確定を待つ
      await new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)))

      const dataUrl = await toPng(captureRoot, {
        pixelRatio: 2,
        backgroundColor: "#ffffff",
        skipAutoScale: true,
        cacheBust: true
      })

      this.showPreview(dataUrl)
    } catch (error) {
      console.error(error)
      this.showError()
    } finally {
      captureRoot?.remove()
    }
  }

  // プレビュー画像をダウンロード
  download(event) {
    event.preventDefault()
    if (!this.hasPreviewImageTarget || !this.previewImageTarget.src) return

    const link = document.createElement("a")
    link.href = this.previewImageTarget.src
    link.download = this.filenameValue || "timetable.png"
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

  showPreview(dataUrl) {
    if (this.hasPreviewImageTarget) {
      this.previewImageTarget.src = dataUrl
    }
    this.#showOnly("previewContent")
  }

  showError() {
    this.#showOnly("errorContent")
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

  #buildCaptureRoot() {
    const header = document.querySelector('[data-timetable-image-part="header"]')
    const days = document.querySelector('[data-timetable-image-part="days"]')
    const grid = document.querySelector('[data-timetable-image-part="grid"]')

    if (!grid) {
      throw new Error("タイムテーブル領域が見つかりません")
    }

    const stageCount = grid.querySelectorAll(".stage-header-col").length
    const width = Math.max(this.minWidthValue, stageCount * this.stageMinWidthValue + 20)

    const root = document.createElement("div")
    root.setAttribute("data-timetable-image-capture-root", "")
    root.style.cssText = [
      "position: fixed",
      "left: 0",
      "top: 0",
      "opacity: 0",
      "pointer-events: none",
      "z-index: -1",
      `width: ${width}px`,
      "background: #ffffff"
    ].join(";")

    if (header) {
      const headerClone = header.cloneNode(true)
      this.#prepareHeader(headerClone)
      root.appendChild(headerClone)
    }

    if (days) {
      const daysClone = days.cloneNode(true)
      this.#prepareDays(daysClone)
      root.appendChild(daysClone)
    }

    const gridClone = grid.cloneNode(true)
    this.#prepareGrid(gridClone, width)
    root.appendChild(gridClone)

    const watermark = document.createElement("div")
    watermark.textContent = "powered by みんなのタイムテーブル"
    watermark.style.cssText = [
      "text-align: right",
      "padding: 8px 12px",
      "font-size: 11px",
      "line-height: 1.4",
      "color: rgba(0, 0, 0, 0.35)",
      "background: #ffffff"
    ].join(";")
    root.appendChild(watermark)

    root.querySelectorAll("[data-timetable-image-hide]").forEach((el) => el.remove())

    return root
  }

  #prepareHeader(el) {
    el.classList.remove("fixed", "top-8", "z-160")
    el.style.position = "relative"
    el.style.top = "auto"
    el.style.left = "auto"
    el.style.width = "100%"
    el.style.zIndex = "auto"
    // 画像ではタイトル全文が見えるように省略を解除する
    el.querySelectorAll(".truncate").forEach((node) => {
      node.classList.remove("truncate")
      node.style.overflow = "visible"
      node.style.textOverflow = "clip"
      node.style.whiteSpace = "normal"
    })
  }

  #prepareDays(el) {
    el.classList.remove("fixed", "top-16", "z-160", "overflow-x-auto")
    el.style.position = "relative"
    el.style.top = "auto"
    el.style.left = "auto"
    el.style.width = "100%"
    el.style.zIndex = "auto"
    el.style.overflow = "visible"
  }

  #prepareGrid(el, width) {
    el.style.width = `${width}px`
    el.style.minWidth = `${width}px`

    el.querySelectorAll(".sticky").forEach((sticky) => {
      sticky.classList.remove("sticky", "top-0", "left-0", "z-110", "z-100", "z-150", "z-95")
      sticky.style.position = "relative"
      sticky.style.top = "auto"
      sticky.style.left = "auto"
      sticky.style.zIndex = "auto"
    })

    el.querySelectorAll("[data-timetable-image-height-rem]").forEach((col) => {
      const rem = col.dataset.timetableImageHeightRem
      if (rem) col.style.height = `${rem}rem`
    })
  }
}
