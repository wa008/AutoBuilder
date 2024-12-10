document.addEventListener('DOMContentLoaded', () => {
    const canvas = document.getElementById('canvas');
    const ctx = canvas.getContext('2d');

    const bgColorInput = document.getElementById('bgColor');
    const textColorInput = document.getElementById('textColor');
    const textInput = document.getElementById('textInput');
    const widthSlider = document.getElementById('widthSlider');
    const heightSlider = document.getElementById('heightSlider');
    const fontSelect = document.getElementById('fontSelect');
    const widthValue = document.getElementById('widthValue');
    const heightValue = document.getElementById('heightValue');

    const drawImage = () => {
        const bgColor = bgColorInput.value;
        const textColor = textColorInput.value;
        const text = textInput.value;
        const width = parseInt(widthSlider.value, 10);
        const height = parseInt(heightSlider.value, 10);
        const font = fontSelect.value;

        canvas.width = width;
        canvas.height = height;

        ctx.fillStyle = bgColor;
        ctx.fillRect(0, 0, width, height);

        ctx.fillStyle = textColor;
        ctx.font = `48px ${font}`;
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';

        const maxWidth = width - 40;
        const lines = wrapText(ctx, text, maxWidth);
        const lineHeight = 48;
        const startY = height / 2 - (lines.length - 1) * lineHeight / 2;

        lines.forEach((line, index) => {
            ctx.fillText(line, width / 2, startY + index * lineHeight);
        });

        widthValue.textContent = width;
        heightValue.textContent = height;
    };

    const wrapText = (context, text, maxWidth) => {
        const words = text.split(' ');
        const lines = [];
        let currentLine = words[0];

        for (let i = 1; i < words.length; i++) {
            const word = words[i];
            const width = context.measureText(currentLine + ' ' + word).width;
            if (width < maxWidth) {
                currentLine += ' ' + word;
            } else {
                lines.push(currentLine);
                currentLine = word;
            }
        }
        lines.push(currentLine);
        return lines;
    };

    const downloadImage = () => {
        const link = document.createElement('a');
        link.download = 'custom-image.png';
        link.href = canvas.toDataURL();
        link.click();
    };

    bgColorInput.addEventListener('input', drawImage);
    textColorInput.addEventListener('input', drawImage);
    textInput.addEventListener('input', drawImage);
    widthSlider.addEventListener('input', drawImage);
    heightSlider.addEventListener('input', drawImage);
    fontSelect.addEventListener('change', drawImage);
    document.getElementById('downloadBtn').addEventListener('click', downloadImage);

    drawImage();
});