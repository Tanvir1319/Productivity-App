const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

// CRC32 table
const crcTable = new Uint32Array(256);
for (let n = 0; n < 256; n++) {
  let c = n;
  for (let k = 0; k < 8; k++) {
    c = (c & 1) ? (0xEDB88320 ^ (c >>> 1)) : (c >>> 1);
  }
  crcTable[n] = c;
}

function crc32(buf) {
  let crc = -1;
  for (let i = 0; i < buf.length; i++) {
    crc = crcTable[(crc ^ buf[i]) & 0xFF] ^ (crc >>> 8);
  }
  return (crc ^ -1) >>> 0;
}

function createChunk(type, data) {
  const len = data.length;
  const chunk = Buffer.alloc(12 + len);
  chunk.writeUInt32BE(len, 0);
  chunk.write(type, 4, 4, 'ascii');
  data.copy(chunk, 8);
  const typeAndData = chunk.subarray(4, 8 + len);
  const crc = crc32(typeAndData);
  chunk.writeUInt32BE(crc, 8 + len);
  return chunk;
}

function encodePNG(width, height, rgbaBuffer) {
  const signature = Buffer.from([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  
  // IHDR
  const ihdrData = Buffer.alloc(13);
  ihdrData.writeUInt32BE(width, 0);
  ihdrData.writeUInt32BE(height, 4);
  ihdrData[8] = 8; // 8 bits per channel
  ihdrData[9] = 6; // RGBA
  ihdrData[10] = 0; // Deflate
  ihdrData[11] = 0; // Filter
  ihdrData[12] = 0; // Non-interlaced
  const ihdrChunk = createChunk('IHDR', ihdrData);

  // Scanlines with filter byte 0
  const scanlines = Buffer.alloc(height * (1 + width * 4));
  for (let y = 0; y < height; y++) {
    const rowOffset = y * (1 + width * 4);
    scanlines[rowOffset] = 0; // filter None
    rgbaBuffer.copy(scanlines, rowOffset + 1, y * width * 4, (y + 1) * width * 4);
  }

  const compressedData = zlib.deflateSync(scanlines, { level: 9 });
  const idatChunk = createChunk('IDAT', compressedData);
  const iendChunk = createChunk('IEND', Buffer.alloc(0));

  return Buffer.concat([signature, ihdrChunk, idatChunk, iendChunk]);
}

// Function to render FocusFlow icon at any size
function renderIcon(size) {
  const buf = Buffer.alloc(size * size * 4);
  const center = size / 2;
  const scale = size / 256;

  // Squircle parameters
  const boxRadius = 112 * scale;
  const cornerRadius = 38 * scale;

  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      const idx = (y * size + x) * 4;
      const dx = x - center;
      const dy = y - center;
      const distFromCenter = Math.hypot(dx, dy);

      // Distance to rounded rectangle (squircle)
      const qx = Math.abs(dx) - (boxRadius - cornerRadius);
      const qy = Math.abs(dy) - (boxRadius - cornerRadius);
      const outerDist = Math.hypot(Math.max(0, qx), Math.max(0, qy)) + Math.min(0, Math.max(qx, qy)) - cornerRadius;

      if (outerDist > 1.5) {
        // Outside squircle: transparent
        buf[idx] = 0; buf[idx+1] = 0; buf[idx+2] = 0; buf[idx+3] = 0;
        continue;
      }

      // Smooth antialiased border
      let squircleAlpha = 1.0;
      if (outerDist > -1.5) {
        squircleAlpha = Math.max(0, Math.min(1, (1.5 - outerDist) / 3.0));
      }

      // Background gradient: dark sleek cosmic gradient
      // Top-left: #131832 -> Bottom-right: #090c18
      const gradT = (dx + dy + boxRadius * 1.5) / (boxRadius * 3);
      let r = 16 + (9 - 16) * gradT;
      let g = 21 + (12 - 21) * gradT;
      let b = 48 + (24 - 48) * gradT;

      // Squircle glowing border rim (outerDist between -3.5 and 0)
      if (outerDist >= -4.5 * scale) {
        const rimIntensity = Math.exp(-Math.pow((outerDist + 1.5 * scale) / (2.0 * scale), 2));
        // Purple to Cyan gradient along perimeter
        const angle = Math.atan2(dy, dx);
        const rimT = (Math.sin(angle - Math.PI / 4) + 1) / 2;
        r = r * (1 - rimIntensity) + (124 * (1 - rimT) + 56 * rimT) * rimIntensity;
        g = g * (1 - rimIntensity) + (92 * (1 - rimT) + 189 * rimT) * rimIntensity;
        b = b * (1 - rimIntensity) + (252 * (1 - rimT) + 248 * rimT) * rimIntensity;
      }

      // Inside graphics: Focus Target + Dynamic Flow Elements
      // 1. Outer target ring at radius ~68 * scale
      const ring1Dist = Math.abs(distFromCenter - 68 * scale);
      if (ring1Dist < 6.5 * scale) {
        const ringAlpha = Math.exp(-Math.pow(ring1Dist / (2.2 * scale), 2));
        const angle = Math.atan2(dy, dx);
        const t = (Math.sin(angle) + 1) / 2;
        const rr = 124 * (1 - t) + 56 * t;
        const gg = 92 * (1 - t) + 189 * t;
        const bb = 252 * (1 - t) + 248 * t;
        r = r * (1 - ringAlpha) + rr * ringAlpha;
        g = g * (1 - ringAlpha) + gg * ringAlpha;
        b = b * (1 - ringAlpha) + bb * ringAlpha;
      }

      // 2. Middle accent arc ring at radius ~45 * scale
      const ring2Dist = Math.abs(distFromCenter - 45 * scale);
      if (ring2Dist < 5.0 * scale) {
        const ringAlpha = Math.exp(-Math.pow(ring2Dist / (1.8 * scale), 2)) * 0.9;
        r = r * (1 - ringAlpha) + 56 * ringAlpha;
        g = g * (1 - ringAlpha) + 189 * ringAlpha;
        b = b * (1 - ringAlpha) + 248 * ringAlpha;
      }

      // 3. Four focus ticks / crosshairs
      const onXAxis = Math.abs(dy) < 3.0 * scale && (distFromCenter > 52 * scale && distFromCenter < 84 * scale);
      const onYAxis = Math.abs(dx) < 3.0 * scale && (distFromCenter > 52 * scale && distFromCenter < 84 * scale);
      if (onXAxis || onYAxis) {
        const tickDist = Math.min(Math.abs(dx), Math.abs(dy));
        const tickAlpha = Math.exp(-Math.pow(tickDist / (1.5 * scale), 2));
        r = r * (1 - tickAlpha) + 255 * tickAlpha;
        g = g * (1 - tickAlpha) + 255 * tickAlpha;
        b = b * (1 - tickAlpha) + 255 * tickAlpha;
      }

      // 4. Center Glowing Focus Core at center (radius ~18 * scale)
      if (distFromCenter < 24 * scale) {
        const coreAlpha = Math.exp(-Math.pow(distFromCenter / (10 * scale), 2));
        const coreInner = Math.exp(-Math.pow(distFromCenter / (5 * scale), 2));
        // Core glow: cyan to white
        const cr = 100 * (1 - coreInner) + 255 * coreInner;
        const cg = 210 * (1 - coreInner) + 255 * coreInner;
        const cb = 255;
        r = r * (1 - coreAlpha) + cr * coreAlpha;
        g = g * (1 - coreAlpha) + cg * coreAlpha;
        b = b * (1 - coreAlpha) + cb * coreAlpha;
      }

      buf[idx] = Math.round(Math.min(255, Math.max(0, r)));
      buf[idx + 1] = Math.round(Math.min(255, Math.max(0, g)));
      buf[idx + 2] = Math.round(Math.min(255, Math.max(0, b)));
      buf[idx + 3] = Math.round(squircleAlpha * 255);
    }
  }

  return encodePNG(size, size, buf);
}

// Build multi-size ICO from PNGs
function buildICO(pngList) {
  // 6-byte header
  const count = pngList.length;
  const header = Buffer.alloc(6);
  header.writeUInt16LE(0, 0); // reserved
  header.writeUInt16LE(1, 2); // ICO format
  header.writeUInt16LE(count, 4); // count of images

  let offset = 6 + (16 * count);
  const dirEntries = [];
  const imageBuffers = [];

  for (const { size, png } of pngList) {
    const entry = Buffer.alloc(16);
    entry[0] = size === 256 ? 0 : size; // width (0 = 256)
    entry[1] = size === 256 ? 0 : size; // height (0 = 256)
    entry[2] = 0; // colors
    entry[3] = 0; // reserved
    entry.writeUInt16LE(1, 4); // color planes
    entry.writeUInt16LE(32, 6); // bpp
    entry.writeUInt32LE(png.length, 8); // size
    entry.writeUInt32LE(offset, 12); // offset

    dirEntries.push(entry);
    imageBuffers.push(png);
    offset += png.length;
  }

  return Buffer.concat([header, ...dirEntries, ...imageBuffers]);
}

const buildDir = path.join(__dirname, 'build');
if (!fs.existsSync(buildDir)) fs.mkdirSync(buildDir, { recursive: true });

console.log('Rendering FocusFlow icons...');
const sizes = [256, 128, 64, 48, 32, 16];
const pngList = [];

for (const s of sizes) {
  const png = renderIcon(s);
  pngList.push({ size: s, png });
  if (s === 256) {
    fs.writeFileSync(path.join(buildDir, 'icon.png'), png);
    console.log('Created build/icon.png (256x256)');
  }
}

const ico = buildICO(pngList);
fs.writeFileSync(path.join(buildDir, 'icon.ico'), ico);
console.log('Created build/icon.ico (multi-res: 256, 128, 64, 48, 32, 16)!');

