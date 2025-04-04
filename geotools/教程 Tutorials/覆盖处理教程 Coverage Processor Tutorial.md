#### 欢迎

欢迎来到覆盖处理器教程。本教程假设您已完成任一快速入门教程的学习。

请确保您的IDE已配置好GeoTools Jar包访问权限（可通过Maven或Jar目录实现）。所需Maven依赖项将在前置条件章节开头列出。

本教程手册将演示如何直接对栅格对象执行常见操作——如叠加、重采样、裁剪等。

#### 影像分块应用

ImageLab教程已涵盖栅格数据的加载与渲染；本教程将展示使用CoverageProcessor等工具直接对栅格数据执行基础操作（如裁剪和缩放），并利用Arguments工具简化命令行处理。我们将创建一个实用程序，用于将栅格"分块"（为简化逻辑，仅对地理范围进行均分），并可选地对生成的分块进行缩放。
#### 前置条件

以下依赖项可能已在之前示例的pom.xml中添加，但请至少确保包含以下依赖：
```xml
<dependencies>
    <dependency>
        <groupId>org.geotools</groupId>
        <artifactId>gt-shapefile</artifactId>
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
</dependencies>
```

在包`org.geotools.tutorial.coverage`中创建文件`ImageTiler.java`，并粘贴以下包含基础导入、字段及getter/setter的代码框架：
```java
package org.geotools.tutorial.coverage;

import java.io.File;
import java.io.IOException;
import org.geotools.api.geometry.Bounds;
import org.geotools.api.parameter.ParameterValueGroup;
import org.geotools.api.referencing.crs.CoordinateReferenceSystem;
import org.geotools.coverage.grid.GridCoverage2D;
import org.geotools.coverage.grid.io.AbstractGridFormat;
import org.geotools.coverage.grid.io.GridCoverage2DReader;
import org.geotools.coverage.grid.io.GridFormatFinder;
import org.geotools.coverage.processing.CoverageProcessor;
import org.geotools.coverage.processing.Operations;
import org.geotools.gce.geotiff.GeoTiffFormat;
import org.geotools.geometry.jts.ReferencedEnvelope;
import org.geotools.util.Arguments;
import org.geotools.util.factory.Hints;

/**
 * 简单的覆盖数据分块工具，根据指定的水平/垂直块数对地理包络线进行细分。
 * 使用覆盖处理操作。
 */
public class ImageTiler {

    private final int NUM_HORIZONTAL_TILES = 16;
    private final int NUM_VERTICAL_TILES = 8;

    private Integer numberOfHorizontalTiles = NUM_HORIZONTAL_TILES;
    private Integer numberOfVerticalTiles = NUM_VERTICAL_TILES;
    private Double tileScale;
    private File inputFile;
    private File outputDirectory;

    private String getFileExtension(File file) {
        String name = file.getName();
        try {
            return name.substring(name.lastIndexOf(".") + 1);
        } catch (Exception e) {
            return "";
        }
    }

    public Integer getNumberOfHorizontalTiles() {
        return numberOfHorizontalTiles;
    }

    public void setNumberOfHorizontalTiles(Integer numberOfHorizontalTiles) {
        this.numberOfHorizontalTiles = numberOfHorizontalTiles;
    }

    public Integer getNumberOfVerticalTiles() {
        return numberOfVerticalTiles;
    }

    public void setNumberOfVerticalTiles(Integer numberOfVerticalTiles) {
        this.numberOfVerticalTiles = numberOfVerticalTiles;
    }

    public File getInputFile() {
        return inputFile;
    }

    public void setInputFile(File inputFile) {
        this.inputFile = inputFile;
    }

    public File getOutputDirectory() {
        return outputDirectory;
    }

    public void setOutputDirectory(File outputDirectory) {
        this.outputDirectory = outputDirectory;
    }
}

```
>**注意**：此为部分代码片段，完整代码将在后续补充，IDE报错可暂时忽略。

#### 参数处理
由于我们正在创建一个命令行应用程序，因此需要处理命令行参数。GeoTools 提供了一个名为 `Arguments` 的类来简化这一过程。我们将使用该类来解析两个必需参数——输入文件和输出目录，以及几个可选参数——垂直和水平的分块数量，以及分块缩放比例。

```java
public static void main(String[] args) throws Exception {
    Arguments processedArgs = new Arguments(args);
    ImageTiler tiler = new ImageTiler();

    try {
        tiler.setInputFile(new File(processedArgs.getRequiredString("-f")));
        tiler.setOutputDirectory(new File(processedArgs.getRequiredString("-o")));
        tiler.setNumberOfHorizontalTiles(processedArgs.getOptionalInteger("-htc"));
        tiler.setNumberOfVerticalTiles(processedArgs.getOptionalInteger("-vtc"));
        tiler.setTileScale(processedArgs.getOptionalDouble("-scale"));
    } catch (IllegalArgumentException e) {
        System.out.println(e.getMessage());
        printUsage();
        System.exit(1);
    }

    tiler.tile();
}

private static void printUsage() {
    System.out.println("用法: -f 输入文件 -o 输出目录 [-tw 瓦片宽度<默认:256> -th 瓦片高度<默认:256>]");
    System.out.println("-htc 水平瓦片数<默认:16> -vtc 垂直瓦片数<默认:8>");
}
```

#### 加载栅格数据

首先，我们需要加载覆盖数据。GeoTools 提供了 `GridFormatFinder` 和 `AbstractGridFormat`，可以以抽象的方式完成此操作。需要注意的是，在撰写本文时，GeoTiff 处理存在一个小问题，因此我们需要单独处理它。
```java
private void tile() throws IOException {
    AbstractGridFormat format = GridFormatFinder.findFormat(this.getInputFile());
    String fileExtension = this.getFileExtension(this.getInputFile());

    // 处理 GeoTiff 加载时的一个 bug/特性，该 bug 使 format.getReader 无法正确设置相关参数
    Hints hints = null;
    if (format instanceof GeoTiffFormat) {
        hints = new Hints(Hints.FORCE_LONGITUDE_FIRST_AXIS_ORDER, Boolean.TRUE);
    }

    GridCoverage2DReader gridReader = format.getReader(this.getInputFile(), hints);
    GridCoverage2D gridCoverage = gridReader.read(null);
}
```
#### 分割栅格数据

接下来，我们将根据指定的水平和垂直分块数量对覆盖数据进行细分。首先，我们获取覆盖数据的包络范围（envelope），然后按照水平和垂直分块数量对该包络范围进行划分，从而计算出每个分块的宽度和高度。随后，我们遍历水平和垂直方向上的分块数量，依次执行裁剪（crop）和缩放（scale）操作。
```java
ReferencedEnvelope coverageEnvelope = gridCoverage.getEnvelope2D();
double coverageMinX = coverageEnvelope.getMinX();
double coverageMaxX = coverageEnvelope.getMaxX();
double coverageMinY = coverageEnvelope.getMinY();
double coverageMaxY = coverageEnvelope.getMaxY();

int htc = this.getNumberOfHorizontalTiles() != null ? this.getNumberOfHorizontalTiles() : NUM_HORIZONTAL_TILES;
int vtc = this.getNumberOfVerticalTiles() != null ? this.getNumberOfVerticalTiles() : NUM_VERTICAL_TILES;

double geographicTileWidth = (coverageMaxX - coverageMinX) / (double) htc;
double geographicTileHeight = (coverageMaxY - coverageMinY) / (double) vtc;

CoordinateReferenceSystem targetCRS = gridCoverage.getCoordinateReferenceSystem();

// 确保输出目录存在
File tileDirectory = this.getOutputDirectory();
if (!tileDirectory.exists()) {
    tileDirectory.mkdirs();
}

// 循环处理分块
for (int i = 0; i < htc; i++) {
    for (int j = 0; j < vtc; j++) {
        System.out.println("处理索引 i: " + i + ", j: " + j + " 处的瓦片");
        Bounds envelope = getTileEnvelope(coverageMinX, coverageMinY, geographicTileWidth, geographicTileHeight, targetCRS, i, j);
        GridCoverage2D finalCoverage = cropCoverage(gridCoverage, envelope);

        if (this.getTileScale() != null) {
            finalCoverage = scaleCoverage(finalCoverage);
        }

        File tileFile = new File(tileDirectory, i + "_" + j + "." + fileExtension);
        format.getWriter(tileFile).write(finalCoverage, null);
    }
}
```

#### 创建分块的包络范围

我们将基于分块的索引以及目标分块的宽度和高度来创建每个分块的包络范围：
```java
private Bounds getTileEnvelope(
        double coverageMinX,
        double coverageMinY,
        double geographicTileWidth,
        double geographicTileHeight,
        CoordinateReferenceSystem targetCRS,
        int horizontalIndex,
        int verticalIndex) {

    double envelopeStartX = (horizontalIndex * geographicTileWidth) + coverageMinX;
    double envelopeEndX = envelopeStartX + geographicTileWidth;
    double envelopeStartY = (verticalIndex * geographicTileHeight) + coverageMinY;
    double envelopeEndY = envelopeStartY + geographicTileHeight;

    return new ReferencedEnvelope(envelopeStartX, envelopeEndX, envelopeStartY, envelopeEndY, targetCRS);
}
```

#### **裁剪**
现在，我们已经计算出了分块的包络范围宽度和高度。接下来，我们将遍历所有分块，并根据目标包络范围进行裁剪。在本示例中，我们将手动创建参数，并使用 `CoverageProcessor` 执行 `CoverageCrop` 操作。在下一步中，我们将介绍一些更简单的方法来执行覆盖数据操作。
```java
private GridCoverage2D cropCoverage(GridCoverage2D gridCoverage, Bounds envelope) {
    CoverageProcessor processor = CoverageProcessor.getInstance();
    // 手动创建我们想要的操作和参数的示例
    final ParameterValueGroup param = processor.getOperation("CoverageCrop").getParameters();
    param.parameter("Source").setValue(gridCoverage);
    param.parameter("Envelope").setValue(envelope);
    return (GridCoverage2D) processor.doOperation(param);
}
```
#### **缩放**
我们可以使用 `Scale` 操作来选择性地缩放我们的分块。在本示例中，我们将使用 `Operations` 类来简化操作。这个类封装了操作，并提供了一个类型安全性更强的接口。在这里，我们将按相同的缩放因子缩放 X 和 Y 维度，以保持原始覆盖数据的纵横比。
```java
/**
 * 根据设置的 tileScale 缩放覆盖数据
 *
 * <p>作为使用参数执行操作的替代方法，我们可以使用 Operations 类以更类型安全的方式执行操作。
 *
 * @param coverage 要缩放的覆盖数据
 * @return 缩放后的覆盖数据
 */
private GridCoverage2D scaleCoverage(GridCoverage2D coverage) {
    Operations ops = new Operations(null);
    coverage = (GridCoverage2D) ops.scale(coverage, this.getTileScale(), this.getTileScale(), 0, 0);
    return coverage;
}

```
### 运行应用程序

在运行应用前需准备示例数据。推荐使用[Natural Earth]([Natural Earth » 1:50m Natural Earth II - Free vector and raster map data at 1:10m, 1:50m, and 1:110m scales](https://www.naturalearthdata.com/downloads/50m-raster-data/50m-natural-earth-2/))的50米分辨率数据集。
#### 通过IDE运行

若您已使用IDE跟随教程开发，内置的运行功能是最简便的方式。以Eclipse为例：
1. 选择菜单 **Run → Run Configurations**
2. 创建新的**Java Application**配置
![[Pasted image 20250331233214.png]]

在**参数(Arguments)**选项卡中配置：
- **输入文件路径**：指向下载的栅格数据
- **分块参数**：水平16块、垂直8块
- **输出目录**：临时文件夹
- **缩放比例**：2.0

`-f /Users/devon/Downloads/NE2_50M_SR_W/NE2_50M_SR_W.tif -htc 16 -vtc 8 -o /Users/devon/tmp/tiles -scale 2.0`

>**注意**：请替换为实际文件路径和目录。

**Eclipse路径变量技巧**：  
在运行配置中点击**Variables**，使用`file_prompt`（文件选择）和`folder_prompt`（目录选择）动态指定路径：

![[Pasted image 20250331233852.png]]

点击**Run**启动应用。可能出现的`ImageIO`相关警告信息可忽略。
其他IDE（如NetBeans/IntelliJ）的配置方式类似。

#### 通过Maven运行

若无IDE，可通过Maven的`exec`任务运行应用（参考[Maven快速入门]([Maven Quickstart — GeoTools 33-SNAPSHOT User Guide](https://docs.geotools.org/latest/userguide/tutorial/quickstart/maven.html))）。需在`pom.xml`中添加Maven Shade插件：
```java
mvn exec:java -Dexec.mainClass=org.geotools.tutorial.ImageTiler \  
-Dexec.args="-f /Users/devon/Downloads/NE2_50M_SR_W/NE2_50M_SR_W.tif -htc 16 -vtc 8 -o /Users/devon/tmp/tiles -scale 2.0"  
```

#### **尝试的事项**

有关覆盖数据操作的更多信息，请参阅[Coverage Processor](http://docs.geotools.org/latest/javadocs/index.html?org/geotools/coverage/processing/CoverageProcessor.html)文档。覆盖处理器中提供的操作之一是 `Resample`（请参见 [`Operations`](http://docs.geotools.org/latest/javadocs/org/geotools/coverage/processing/Operations.html) 类），我们可以使用它轻松地重新投影我们的覆盖数据。尝试将覆盖数据重新投影到 EPSG:3587（Google 的 Web Mercator 投影）。

我们可以通过将分块加载到 GeoServer 的 [ImageMosaic](http://docs.geoserver.org/latest/en/user/data/raster/imagemosaic/index.html) 存储中来验证它们是否正常。或者，我们也可以通过编程方式创建指向我们目录文件的 [`ImageMosaicReader`](http://docs.geotools.org/latest/javadocs/org/geotools/gce/imagemosaic/ImageMosaicReader.html)，并从中读取数据。