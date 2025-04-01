
#### 欢迎

欢迎来到Java地理空间开发。本教程面向刚接触地理空间数据并希望入门的Java开发者。

请确保您的IDE已配置好GeoTools Jar包（可通过Maven或本地Jar目录）。使用Maven的开发者可在每章开头找到所需依赖项。

本教程延续"代码优先"风格，您可直接运行Java程序实践概念，再通过阅读文档深入理解。

本章重点讲解`GridCoverage`（计算机领域常称为栅格或位图）的处理。栅格覆盖指地图表面被无缝覆盖的数据层，而网格覆盖是栅格覆盖的特例，其特征在地球表面表现为矩形阵列。此概念与像素高度相似，因此我们常用相同文件格式表示网格覆盖。
#### 影像实验室应用

此前示例演示了Shapefile的读取与展示。在`ImageLab.java`中，我们将通过以下步骤增强功能：
1. 显示三波段全球卫星影像
2. 叠加Shapefile中的国界数据

请确保`pom.xml`包含以下依赖：

```xml
<dependencies>
    <dependency>
        <groupId>org.geotools</groupId>
        <artifactId>gt-shapefile</artifactId>
        <version>${geotools.version}</version>
    </dependency>
    <dependency>
        <groupId>org.geotools</groupId>
        <artifactId>gt-swing</artifactId>
        <version>${geotools.version}</version>
    </dependency>
    <dependency>
        <groupId>org.geotools</groupId>
        <artifactId>gt-epsg-hsql</artifactId>
        <version>${geotools.version}</version>
    </dependency>
    <dependency>
        <groupId>org.geotools</groupId>
        <artifactId>gt-geotiff</artifactId>
        <version>${geotools.version}</version>
    </dependency>
    <dependency>
        <groupId>org.geotools</groupId>
        <artifactId>gt-image</artifactId>
        <version>${geotools.version}</version>
    </dependency>
    <dependency>
        <groupId>org.geotools</groupId>
        <artifactId>gt-wms</artifactId>
        <version>${geotools.version}</version>
    </dependency>
</dependencies>
<!-- OSGeo仓库配置 -->
<repositories>
    <repository>
        <id>osgeo</id>
        <name>OSGeo Release Repository</name>
        <url>https://repo.osgeo.org/repository/release/</url>
        <snapshots><enabled>false</enabled></snapshots>
        <releases><enabled>true</enabled></releases>
    </repository>
    <repository>
        <id>osgeo-snapshot</id>
        <name>OSGeo Snapshot Repository</name>
        <url>https://repo.osgeo.org/repository/snapshot/</url>
        <snapshots><enabled>true</enabled></snapshots>
        <releases><enabled>false</enabled></releases>
    </repository>
</repositories>
```

在包`org.geotools.tutorial.raster`中创建类`ImageLab`并粘贴以下代码框架：

```java
package org.geotools.tutorial.raster;

import java.awt.Color;
import java.awt.event.ActionEvent;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JOptionPane;
import org.geotools.api.data.FileDataStore;
import org.geotools.api.data.FileDataStoreFinder;
import org.geotools.api.data.Parameter;
import org.geotools.api.data.SimpleFeatureSource;
import org.geotools.api.filter.FilterFactory;
import org.geotools.api.style.ChannelSelection;
import org.geotools.api.style.ContrastEnhancement;
import org.geotools.api.style.ContrastMethod;
import org.geotools.api.style.RasterSymbolizer;
import org.geotools.api.style.SelectedChannelType;
import org.geotools.api.style.Style;
import org.geotools.api.style.StyleFactory;
import org.geotools.coverage.GridSampleDimension;
import org.geotools.coverage.grid.GridCoverage2D;
import org.geotools.coverage.grid.io.AbstractGridFormat;
import org.geotools.coverage.grid.io.GridCoverage2DReader;
import org.geotools.coverage.grid.io.GridFormatFinder;
import org.geotools.factory.CommonFactoryFinder;
import org.geotools.gce.geotiff.GeoTiffFormat;
import org.geotools.map.FeatureLayer;
import org.geotools.map.GridReaderLayer;
import org.geotools.map.Layer;
import org.geotools.map.MapContent;
import org.geotools.map.StyleLayer;
import org.geotools.styling.SLD;
import org.geotools.swing.JMapFrame;
import org.geotools.swing.action.SafeAction;
import org.geotools.swing.data.JParameterListWizard;
import org.geotools.swing.wizard.JWizard;
import org.geotools.util.KVP;
import org.geotools.util.factory.Hints;

public class ImageLab {

    private StyleFactory sf = CommonFactoryFinder.getStyleFactory();
    private FilterFactory ff = CommonFactoryFinder.getFilterFactory();

    private JMapFrame frame;
    private GridCoverage2DReader reader;

    public static void main(String[] args) throws Exception {
        ImageLab me = new ImageLab();
        me.getLayersAndDisplay();
    }

```

### 参数向导实现详解

#### 参数收集机制
在GeoTools中，数据存储向导(`DataStore wizards`)是通过定义连接所需的参数动态生成的。以下展示如何使用`JParameterListWizard`构建文件选择界面：

```java
/**
 * 通过向导对话框获取用户输入的栅格文件和Shapefile
 * 并将选择的文件传递给显示方法
 */
private void getLayersAndDisplay() throws Exception {
    // 1. 定义参数列表
    List<Parameter<?>> params = new ArrayList<>();
    
    // 2. 配置栅格文件参数
    params.add(new Parameter<>(
            "image",                    // 参数键名
            File.class,                 // 参数类型（文件类）
            "影像文件",                  // 界面显示的标题
            "作为底图的GeoTIFF或World+Image文件", // 帮助说明
            new KVP(                    // 元数据键值对
                Parameter.EXT, "tif",    // 限制文件扩展名为.tif
                Parameter.EXT, "jpg"    // 或.jpg
            )));
    
    // 3. 配置Shapefile参数
    params.add(new Parameter<>(
            "shape", 
            File.class, 
            "Shapefile", 
            "需要叠加显示的矢量数据", 
            new KVP(Parameter.EXT, "shp")));

    // 4. 创建参数向导对话框
    JParameterListWizard wizard = new JParameterListWizard(
            "影像实验室",                 // 窗口标题
            "请选择需要加载的数据文件",    // 引导提示
            params);                    // 参数定义
    
    // 5. 显示模态对话框
    int result = wizard.showModalDialog();
    
    // 6. 处理用户取消操作
    if (result != JWizard.FINISH) {
        System.exit(0);
    }
    
    // 7. 获取用户选择结果
    File imageFile = (File) wizard.getConnectionParameters().get("image");
    File shapeFile = (File) wizard.getConnectionParameters().get("shape");
    
    // 8. 调用显示方法
    displayLayers(imageFile, shapeFile);
}
```

#### Parameter构造函数参数详解
| 参数项      | 类型       | 说明                   | 示例值          |
| -------- | -------- | -------------------- | ------------ |
| **key**  | String   | 参数的唯一标识符，用于后续从结果中提取值 | `"image"`    |
| **type** | Class<?> | 参数值的Java类型，决定输入验证规则  | `File.class` |
| **title** | String | 在界面上显示的字段标签 | "影像文件"`    |
| **description**|String| 在界面显示的帮助文本（通常位于输入框下方）| `"作为底图的GeoTIFF文件"`|
| **metadata**  | Map<String,?> | 扩展属性键值对，常用`Parameter.EXT`指定文件扩展名过滤              | `new KVP(Parameter.EXT, "tif")`    |

#### 关键特性说明
1. **文件类型过滤**  
   通过`KVP`(Key-Value Pair)设置`Parameter.EXT`可限制文件选择对话框只显示特定扩展名的文件：
   ```java
   new KVP(Parameter.EXT, "tif", Parameter.EXT, "jpg")
   ```

2. **模态对话框控制**  
   `showModalDialog()`方法会阻塞当前线程直到用户完成操作，返回值判断：
   - `JWizard.FINISH`：用户确认
   - 其他值：用户取消

3. **结果获取**  
   通过向导对象的`getConnectionParameters()`方法，使用定义时的key提取用户输入：
   ```java
   File file = (File)wizard.getConnectionParameters().get("image");
   ```

#### 可视化效果
该代码将生成包含以下元素的对话框：
1. 顶部标题栏显示"影像实验室"
2. 描述文字"请选择需要加载的数据文件"
3. 两个文件选择输入框：
   - 标签为"影像文件"，附带说明文字
   - 文件选择器自动过滤.tif/.jpg文件
4. 标准确定/取消按钮

> **最佳实践建议**：对于生产环境应用，建议增加文件存在性验证逻辑，在调用`displayLayers()`前检查`imageFile.exists()`。
---

#### 地图可视化
创建地图容器`MapContent`，添加栅格与矢量图层，并通过`JMapFrame`实现交互式展示：

```java

/** 展示栅格与矢量叠加地图 */
private void displayLayers(File rasterFile, File shpFile) throws Exception {
    AbstractGridFormat format = GridFormatFinder.findFormat(rasterFile);
    Hints hints = new Hints();
    if (format instanceof GeoTiffFormat) {
        hints.put(Hints.FORCE_LONGITUDE_FIRST_AXIS_ORDER, Boolean.TRUE); // 修复GeoTiff坐标轴顺序
    }
    reader = format.getReader(rasterFile, hints);

    // 初始灰度样式（使用第1波段）
    Style rasterStyle = createGreyscaleStyle(1);

    // 加载Shapefile
    FileDataStore dataStore = FileDataStoreFinder.getDataStore(shpFile);
    SimpleFeatureSource shapefileSource = dataStore.getFeatureSource();
    Style shpStyle = SLD.createPolygonStyle(Color.YELLOW, null, 0.0f); // 黄色边框样式

    // 构建地图内容
    final MapContent map = new MapContent();
    map.setTitle("影像实验室");
    map.addLayer(new GridReaderLayer(reader, rasterStyle));
    map.addLayer(new FeatureLayer(shapefileSource, shpStyle));

    // 配置交互式窗口
    frame = new JMapFrame(map);
    frame.setSize(800, 600);
    frame.enableStatusBar(true);
    frame.enableToolBar(true);

    // 添加栅格显示模式菜单
    JMenuBar menuBar = new JMenuBar();
    JMenu menu = new JMenu("栅格");
    menu.add(new SafeAction("灰度模式") {
        public void action(ActionEvent e) throws Throwable {
            Style style = createGreyscaleStyle();
            if (style != null) {
                ((StyleLayer) map.layers().get(0)).setStyle(style);
                frame.repaint();
            }
        }
    });
    menu.add(new SafeAction("RGB模式") {
        public void action(ActionEvent e) throws Throwable {
            Style style = createRGBStyle();
            if (style != null) {
                ((StyleLayer) map.layers().get(0)).setStyle(style);
                frame.repaint();
            }
        }
    });
    menuBar.add(menu);
    frame.setJMenuBar(menuBar);
    frame.setVisible(true);
}
```

---

#### 样式构建

**灰度样式**：通过波段选择与对比度增强实现

```java
/** 创建单波段灰度样式 */
private Style createGreyscaleStyle(int band) {
    ContrastEnhancement ce = sf.contrastEnhancement(ff.literal(1.0), ContrastMethod.NORMALIZE);
    SelectedChannelType sct = sf.createSelectedChannelType(String.valueOf(band), ce);

    RasterSymbolizer sym = sf.getDefaultRasterSymbolizer();
    sym.setChannelSelection(sf.channelSelection(sct));
    return SLD.wrapSymbolizers(sym);
}

/** 弹出对话框选择灰度波段 */
private Style createGreyscaleStyle() {
    GridCoverage2D cov = reader.read(null);
    Integer[] bands = IntStream.rangeClosed(1, cov.getNumSampleDimensions()).boxed().toArray(Integer[]::new);
    Object selection = JOptionPane.showInputDialog(/* 参数省略 */);
    return selection != null ? createGreyscaleStyle((Integer) selection) : null;
}
```

**RGB样式**：自动匹配波段或使用默认顺序

```java
/** 创建RGB合成样式 */
private Style createRGBStyle() {
    GridCoverage2D cov = reader.read(null);
    if (cov.getNumSampleDimensions() < 3) return null;

    String[] bandNames = new String[cov.getNumSampleDimensions()];
    Arrays.setAll(bandNames, i -> cov.getSampleDimension(i).getDescription().toString().toLowerCase());

    int[] channels = {-1, -1, -1};
    for (int i = 0; i < bandNames.length; i++) {
        if (bandNames[i].matches("red.*")) channels[0] = i+1;
        else if (bandNames[i].matches("green.*")) channels[1] = i+1;
        else if (bandNames[i].matches("blue.*")) channels[2] = i+1;
    }
    // 默认使用前三个波段
    if (channels[0] < 0) Arrays.setAll(channels, i -> i+1);

    SelectedChannelType[] sct = new SelectedChannelType[3];
    ContrastEnhancement ce = sf.contrastEnhancement(ff.literal(1.0), ContrastMethod.NORMALIZE);
    Arrays.setAll(sct, i -> sf.createSelectedChannelType(String.valueOf(channels[i]), ce));

    RasterSymbolizer sym = sf.getDefaultRasterSymbolizer();
    sym.setChannelSelection(sf.channelSelection(sct[0], sct[1], sct[2]));
    return SLD.wrapSymbolizers(sym);
}
```

---

### 技术提示

1. **波段匹配逻辑**
    
    - 优先通过波段描述名称（如"red_band"）识别RGB通道
        
    - 未命名时默认使用前三个波段
        
    - 卫星影像等复杂数据需人工指定波段组合
        
2. **样式动态更新**
    
    - 通过`StyleLayer.setStyle()`实现实时渲染模式切换
        
    - 对比度增强参数可根据数据特性调整