const express = require('express')
const { render } = require('@antv/gpt-vis-ssr')
const fs = require('fs-extra')
const path = require('path')
const { v4: uuidv4 } = require('uuid')

const app = express()
const port = process.env.PORT || 3000
const publicDir = path.join(__dirname, 'public')
const imagesDir = path.join(publicDir, 'images')

// 确保目录存在
fs.ensureDirSync(imagesDir)

app.use(express.json())
app.use('/images', express.static(imagesDir))

app.post('/render', async (req, res) => {
  try {
    const options = req.body

    // 验证必要的参数
    if (!options || !options.type || !options.data) {
      return res.status(400).json({
        success: false,
        errorMessage: '缺少必要的参数: type 或 data'
      })
    }

    // 渲染图表
    const vis = await render(options)
    const buffer = await vis.toBuffer()

    // 生成唯一文件名并保存图片
    const filename = `${uuidv4()}.png`
    const filePath = path.join(imagesDir, filename)
    await fs.writeFile(filePath, buffer)

    // 构建图片URL
    const host = req.get('host')
    const protocol = req.protocol
    const imageUrl = `${protocol}://${host}/images/${filename}`

    res.json({
      success: true,
      resultObj: imageUrl
    })
  } catch (error) {
    console.error('渲染图表时出错:', error)
    res.status(500).json({
      success: false,
      errorMessage: `渲染图表失败: ${error.message}`
    })
  }
})

app.listen(port, () => {
  console.log(`GPT-Vis-SSR 服务运行在 http://localhost:${port}`)
})