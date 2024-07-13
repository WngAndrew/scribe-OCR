export async function performOCR(imageDataUrl) {
    const worker = await Tesseract.createWorker();
    await worker.load();
    await worker.loadLanguage('eng');
    await worker.initialize('eng');
    
    const { data: { text } } = await worker.recognize(imageDataUrl);
    await worker.terminate();
    return text;
  }

  window.performOCR = performOCR;
  