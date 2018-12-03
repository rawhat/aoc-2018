const fs = require('fs')
const {promisify} = require("util")

const readFile = promisify(fs.readFile)

async function main() { 
  const sums = []
  let lines = await readFile("pt1-input.txt", 'utf-8')
  lines = lines.split("\n").map(n => parseInt(n)).filter(e => !isNaN(e))
  let found = false
  let lineIndex = 0
  while (true) {
    const next_num = lines[lineIndex] + (sums[sums.length - 1] || 0)
    if (sums.includes(next_num)) {
      console.log(next_num)
      break
    }
    sums.push(next_num)
    lineIndex = (lineIndex + 1) % lines.length
  }
}

main()