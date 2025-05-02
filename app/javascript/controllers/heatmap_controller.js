import { Controller } from "@hotwired/stimulus"
import * as d3 from "d3"

export default class extends Controller {
  static targets = ["canvas"]
  
  connect() {
    this.loadData()
  }
  
  loadData() {
    const canvas = document.getElementById("heatmap")
    const dataUrl = canvas.dataset.url
    
    fetch(dataUrl)
      .then(response => response.json())
      .then(data => this.renderHeatmap(data, canvas))
      .catch(error => console.error("Error loading heatmap data:", error))
  }
  
  renderHeatmap(data, canvas) {
    if (!data || !data.users || !data.matrix) return
    
    const users = data.users
    const matrix = data.matrix
    
    // Shuffle rows and columns on every page load (as per requirements)
    const shuffledIndices = [...Array(users.length).keys()]
      .sort(() => Math.random() - 0.5)
    
    const shuffledUsers = shuffledIndices.map(i => users[i])
    const shuffledMatrix = shuffledIndices.map(i => {
      return shuffledIndices.map(j => matrix[i][j])
    })
    
    const ctx = canvas.getContext("2d")
    const width = canvas.width = 800
    const height = canvas.height = 800
    const padding = 60
    const cellSize = (width - (padding * 2)) / shuffledUsers.length
    
    ctx.clearRect(0, 0, width, height)
    
    // Draw user labels
    ctx.font = "12px sans-serif"
    ctx.textAlign = "right"
    ctx.textBaseline = "middle"
    
    shuffledUsers.forEach((user, i) => {
      // Row labels (Y-axis)
      ctx.fillText(user.name, padding - 10, padding + (i * cellSize) + (cellSize / 2))
      
      // Column labels (X-axis)
      ctx.save()
      ctx.translate(padding + (i * cellSize) + (cellSize / 2), padding - 10)
      ctx.rotate(-Math.PI / 4)
      ctx.textAlign = "right"
      ctx.fillText(user.name, 0, 0)
      ctx.restore()
    })
    
    // Draw heatmap cells
    shuffledMatrix.forEach((row, i) => {
      row.forEach((value, j) => {
        if (value === null) return // Skip empty cells (self-feedback)
        
        const x = padding + (j * cellSize)
        const y = padding + (i * cellSize)
        
        // Use d3 color interpolation as specified in requirements
        const normalizedValue = (value + 5) / 10 // Map -5..5 to 0..1
        const color = d3.interpolateRdYlGn(normalizedValue)
        
        // Draw cell background
        ctx.fillStyle = color
        ctx.fillRect(x, y, cellSize, cellSize)
        
        // Draw cell border
        ctx.strokeStyle = "#ddd"
        ctx.strokeRect(x, y, cellSize, cellSize)
        
        // Draw average value in cell (rounded up as per requirements)
        if (value !== null) {
          const displayValue = Math.ceil(value)
          ctx.fillStyle = this.getContrastColor(color)
          ctx.font = "bold 14px sans-serif"
          ctx.textAlign = "center"
          ctx.textBaseline = "middle"
          ctx.fillText(displayValue, x + (cellSize / 2), y + (cellSize / 2))
        }
      })
    })
  }
  
  // Helper to determine text color based on background for readability
  getContrastColor(hexColor) {
    // Convert hex color to RGB to calculate luminance
    const r = parseInt(hexColor.substr(1, 2), 16) / 255
    const g = parseInt(hexColor.substr(3, 2), 16) / 255
    const b = parseInt(hexColor.substr(5, 2), 16) / 255
    
    // Calculate luminance using the formula for relative luminance
    const luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
    
    // Return white for dark backgrounds, black for light backgrounds
    return luminance > 0.5 ? "#000000" : "#ffffff"
  }
} 