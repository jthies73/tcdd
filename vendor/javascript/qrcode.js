/**
 * Simple QR Code Generator using Canvas API
 * 
 * This implementation uses a simplified QR code algorithm suitable for short URLs.
 * For production use, consider using a well-tested library like qrcode-generator.
 */

// QR Code generator using a simple implementation
class QRCodeGenerator {
  constructor() {
    // Generator polynomial for error correction
    this.gf = this.initGaloisField()
  }

  initGaloisField() {
    const exp = new Array(256)
    const log = new Array(256)
    let x = 1
    for (let i = 0; i < 255; i++) {
      exp[i] = x
      log[x] = i
      x = x << 1
      if (x >= 256) x ^= 0x11d
    }
    exp[255] = exp[0]
    return { exp, log }
  }

  // Generate SVG QR code
  generate(text, size = 200) {
    try {
      const modules = this.createModules(text)
      return this.toSVG(modules, size)
    } catch (e) {
      console.error('QR generation error:', e)
      throw e
    }
  }

  createModules(text) {
    const data = new TextEncoder().encode(text)
    const version = this.getVersion(data.length)
    const size = version * 4 + 17
    
    // Initialize modules matrix
    const modules = Array(size).fill(null).map(() => Array(size).fill(null))
    const isFunction = Array(size).fill(null).map(() => Array(size).fill(false))

    // Add function patterns
    this.addFinderPatterns(modules, isFunction, size)
    this.addTimingPatterns(modules, isFunction, size)
    this.addAlignmentPatterns(modules, isFunction, size, version)
    
    // Reserve format information area
    this.reserveFormatArea(isFunction, size)
    
    // Add dark module
    modules[size - 8][8] = true
    isFunction[size - 8][8] = true

    // Encode and place data
    const encoded = this.encodeData(data, version)
    this.placeData(modules, isFunction, encoded, size)
    
    // Apply mask pattern 0 (simplest)
    this.applyMask(modules, isFunction, size, 0)
    
    // Add format info
    this.addFormatInfo(modules, size, 0, 1) // mask 0, EC level M
    
    return modules
  }

  getVersion(dataLength) {
    // Capacity table for byte mode, EC level M
    const capacity = [0, 14, 26, 42, 62, 84, 106, 122, 152, 180, 213]
    for (let v = 1; v <= 10; v++) {
      if (dataLength <= capacity[v]) return v
    }
    throw new Error('Data too long')
  }

  addFinderPatterns(modules, isFunction, size) {
    const positions = [[0, 0], [0, size - 7], [size - 7, 0]]
    for (const [row, col] of positions) {
      for (let r = -1; r <= 7; r++) {
        for (let c = -1; c <= 7; c++) {
          const nr = row + r
          const nc = col + c
          if (nr >= 0 && nr < size && nc >= 0 && nc < size) {
            const inOuter = r === 0 || r === 6 || c === 0 || c === 6
            const inMiddle = r >= 2 && r <= 4 && c >= 2 && c <= 4
            modules[nr][nc] = (r >= 0 && r <= 6 && c >= 0 && c <= 6) && (inOuter || inMiddle)
            isFunction[nr][nc] = true
          }
        }
      }
    }
  }

  addTimingPatterns(modules, isFunction, size) {
    for (let i = 8; i < size - 8; i++) {
      modules[6][i] = modules[i][6] = i % 2 === 0
      isFunction[6][i] = isFunction[i][6] = true
    }
  }

  addAlignmentPatterns(modules, isFunction, size, version) {
    if (version < 2) return
    const positions = [6, 6 + version * 4]
    for (const row of positions) {
      for (const col of positions) {
        if ((row === 6 && col === 6) || (row === 6 && col > size - 10) || (row > size - 10 && col === 6)) continue
        for (let r = -2; r <= 2; r++) {
          for (let c = -2; c <= 2; c++) {
            const isBlack = Math.max(Math.abs(r), Math.abs(c)) !== 1
            if (row + r >= 0 && row + r < size && col + c >= 0 && col + c < size) {
              modules[row + r][col + c] = isBlack
              isFunction[row + r][col + c] = true
            }
          }
        }
      }
    }
  }

  reserveFormatArea(isFunction, size) {
    for (let i = 0; i < 9; i++) {
      isFunction[i][8] = true
      isFunction[8][i] = true
    }
    for (let i = 0; i < 8; i++) {
      isFunction[size - 1 - i][8] = true
      isFunction[8][size - 1 - i] = true
    }
  }

  encodeData(data, version) {
    const bits = []
    
    // Mode indicator for byte mode
    bits.push(0, 1, 0, 0)
    
    // Character count (8 bits for versions 1-9)
    for (let i = 7; i >= 0; i--) {
      bits.push((data.length >> i) & 1)
    }
    
    // Data bytes
    for (const byte of data) {
      for (let i = 7; i >= 0; i--) {
        bits.push((byte >> i) & 1)
      }
    }
    
    // Terminator and padding
    const size = version * 4 + 17
    const totalBits = this.getDataCapacity(version) * 8
    
    // Add terminator
    for (let i = 0; i < 4 && bits.length < totalBits; i++) {
      bits.push(0)
    }
    
    // Pad to byte boundary
    while (bits.length % 8 !== 0 && bits.length < totalBits) {
      bits.push(0)
    }
    
    // Add padding bytes
    const padBytes = [0xEC, 0x11]
    let padIndex = 0
    while (bits.length < totalBits) {
      for (let i = 7; i >= 0 && bits.length < totalBits; i--) {
        bits.push((padBytes[padIndex] >> i) & 1)
      }
      padIndex = 1 - padIndex
    }
    
    return bits
  }

  getDataCapacity(version) {
    // Data codewords for EC level M
    const capacity = [0, 16, 28, 44, 64, 86, 108, 124, 154, 182, 216]
    return capacity[version]
  }

  placeData(modules, isFunction, bits, size) {
    let bitIndex = 0
    let upward = true
    
    for (let col = size - 1; col >= 1; col -= 2) {
      if (col === 6) col = 5
      
      for (let count = 0; count < size; count++) {
        const row = upward ? size - 1 - count : count
        
        for (let c = 0; c < 2; c++) {
          const actualCol = col - c
          if (!isFunction[row][actualCol]) {
            if (bitIndex < bits.length) {
              modules[row][actualCol] = bits[bitIndex] === 1
              bitIndex++
            } else {
              modules[row][actualCol] = false
            }
          }
        }
      }
      upward = !upward
    }
  }

  applyMask(modules, isFunction, size, mask) {
    for (let row = 0; row < size; row++) {
      for (let col = 0; col < size; col++) {
        if (!isFunction[row][col]) {
          let shouldFlip = false
          switch (mask) {
            case 0: shouldFlip = (row + col) % 2 === 0; break
            case 1: shouldFlip = row % 2 === 0; break
            case 2: shouldFlip = col % 3 === 0; break
            case 3: shouldFlip = (row + col) % 3 === 0; break
            case 4: shouldFlip = (Math.floor(row / 2) + Math.floor(col / 3)) % 2 === 0; break
            case 5: shouldFlip = (row * col) % 2 + (row * col) % 3 === 0; break
            case 6: shouldFlip = ((row * col) % 2 + (row * col) % 3) % 2 === 0; break
            case 7: shouldFlip = ((row + col) % 2 + (row * col) % 3) % 2 === 0; break
          }
          if (shouldFlip) {
            modules[row][col] = !modules[row][col]
          }
        }
      }
    }
  }

  addFormatInfo(modules, size, mask, ecLevel) {
    const data = (ecLevel << 3) | mask
    let rem = data
    for (let i = 0; i < 10; i++) {
      rem = (rem << 1) ^ ((rem >> 9) * 0x537)
    }
    const bits = ((data << 10) | rem) ^ 0x5412
    
    // Place format info bits
    for (let i = 0; i <= 5; i++) {
      modules[8][i] = ((bits >> i) & 1) === 1
    }
    modules[8][7] = ((bits >> 6) & 1) === 1
    modules[8][8] = ((bits >> 7) & 1) === 1
    modules[7][8] = ((bits >> 8) & 1) === 1
    for (let i = 9; i < 15; i++) {
      modules[14 - i][8] = ((bits >> i) & 1) === 1
    }
    
    for (let i = 0; i < 8; i++) {
      modules[size - 1 - i][8] = ((bits >> i) & 1) === 1
    }
    for (let i = 8; i < 15; i++) {
      modules[8][size - 15 + i] = ((bits >> i) & 1) === 1
    }
  }

  toSVG(modules, size) {
    const moduleSize = modules.length
    const cellSize = size / moduleSize
    
    let svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}" viewBox="0 0 ${moduleSize} ${moduleSize}">`
    svg += `<rect width="100%" height="100%" fill="white"/>`
    
    for (let row = 0; row < moduleSize; row++) {
      for (let col = 0; col < moduleSize; col++) {
        if (modules[row][col]) {
          svg += `<rect x="${col}" y="${row}" width="1" height="1" fill="black"/>`
        }
      }
    }
    
    svg += '</svg>'
    return svg
  }
}

// Create singleton instance
const generator = new QRCodeGenerator()

// Export class for ES module usage
export class QRCode {
  constructor(text, options = {}) {
    this.text = text
    this.options = options
    this.svgString = generator.generate(text, options.size || 200)
  }

  toSVG(options = {}) {
    const size = options.size || 200
    return generator.generate(this.text, size)
  }

  toSVGElement(options = {}) {
    const parser = new DOMParser()
    const doc = parser.parseFromString(this.toSVG(options), 'image/svg+xml')
    return doc.documentElement
  }
}

export function createQRCode(text, options = {}) {
  return new QRCode(text, options)
}

export default { QRCode, createQRCode }
