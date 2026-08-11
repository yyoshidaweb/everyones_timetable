import { Controller } from "@hotwired/stimulus"
import { domToPng } from "modern-screenshot"

// タイムテーブルを画像化してプレビュー・保存する
export default class extends Controller {
  static targets = [
    "shareContent",
    "daySelectContent",
    "dayList",
    "loadingContent",
    "previewContent",
    "errorContent",
    "errorMessage",
    "previewImage"
  ]
  static values = {
    filename: String,
    filenameTemplate: String,
    captureUrl: String,
    days: { type: Array, default: [] }
  }

  // 「画像を保存」→日付選択（複数日）またはそのまま生成
  start(event) {
    event.preventDefault()

    if (!this.daysValue.length) {
      this.showError("開催日がありません。")
      return
    }

    if (this.daysValue.length === 1) {
      this.#generateForDate(this.daysValue[0])
      return
    }

    this.#renderDayList()
    this.#showOnly("daySelectContent")
  }

  // 日付ボタンから生成
  selectDay(event) {
    event.preventDefault()
    const date = event.currentTarget.dataset.date
    const day = this.daysValue.find((item) => item.date === date)
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

  showError(message) {
    if (this.hasErrorMessageTarget && message) {
      this.errorMessageTarget.innerHTML = message
    }
    this.#showOnly("errorContent")
  }

  async #generateForDate(day) {
    this.filenameValue = day.filename || this.#filenameFor(day.date)
    this.showLoading()

    let captureRoot = null
    try {
      captureRoot = await this.#fetchCaptureRoot(day.date)
      document.body.appendChild(captureRoot)

      if (document.fonts?.ready) {
        await document.fonts.ready
      }
      await new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)))

      const dataUrl = await domToPng(captureRoot, {
        scale: 2,
        backgroundColor: "#ffffff"
      })

      this.showPreview(dataUrl)
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

    // 画面外に置く（opacity:0 はキャプチャが真っ白になるため使わない）
    root.style.position = "fixed"
    root.style.left = "-10000px"
    root.style.top = "0"
    root.style.pointerEvents = "none"
    root.style.zIndex = "0"

    return root
  }

  #renderDayList() {
    if (!this.hasDayListTarget) return

    this.dayListTarget.innerHTML = ""
    this.daysValue.forEach((day) => {
      const button = document.createElement("button")
      button.type = "button"
      button.dataset.date = day.date
      button.dataset.action = "click->timetable-image#selectDay"
      button.className = "w-full py-2 rounded-full bg-gray-800 text-white font-semibold cursor-pointer hover:bg-gray-900"
      button.textContent = day.label
      this.dayListTarget.appendChild(button)
    })
  }

  #filenameFor(date) {
    const mmdd = date.slice(5, 7) + date.slice(8, 10)
    if (this.filenameTemplateValue) {
      return this.filenameTemplateValue.replace("DATE", mmdd)
    }
    return `timetable_${mmdd}.png`
  }

  #showOnly(targetName) {
    const map = {
      shareContent: this.hasShareContentTarget ? this.shareContentTarget : null,
      daySelectContent: this.hasDaySelectContentTarget ? this.daySelectContentTarget : null,
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
