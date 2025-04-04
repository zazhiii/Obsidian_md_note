欢迎 
欢迎来到Java地理空间开发。本教程面向刚接触地理空间数据的Java开发者。

### **准备工作**
- 请确保已完成GeoTools任一[快速入门](https://docs.geotools.org/latest/userguide/tutorial/quickstart/index.html)教程
- 开发环境需配置好GeoTools及其所有依赖项
- 各章节开头会列出所需的Maven依赖

本教程将揭开GIS世界的"数学面纱"——但请放心，我们只需处理地球表面的几何形状问题，无需复杂数学推导。

### **学习特点**
- 采用**代码优先**模式：
    1. 直接运行代码示例
    2. 根据问题查阅后续说明
- 聚焦两大核心概念：
    - **Geometry**（几何图形）
    - **Coordinate Reference System**（坐标参考系，CRS）

本应用通过可视化方式演示坐标参考系统（CRS），展示不同地图投影对要素几何形状的形变效果。
1. 请确保`pom.xml`包含以下关键依赖：
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
    </dependencies>
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

2. 创建包 `org.geotools.tutorial.crs` 和类文件 `CRSLab.java`，并复制粘贴以下代码：
```java
package org.geotools.tutorial.crs;

import java.awt.event.ActionEvent;
import java.io.File;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;
import javax.swing.Action;
import javax.swing.JButton;
import javax.swing.JOptionPane;
import javax.swing.JToolBar;
import javax.swing.SwingWorker;
import org.geotools.api.data.DataStore;
import org.geotools.api.data.DataStoreFactorySpi;
import org.geotools.api.data.FeatureWriter;
import org.geotools.api.data.FileDataStore;
import org.geotools.api.data.FileDataStoreFinder;
import org.geotools.api.data.Query;
import org.geotools.api.data.SimpleFeatureSource;
import org.geotools.api.data.SimpleFeatureStore;
import org.geotools.api.data.Transaction;
import org.geotools.api.feature.Feature;
import org.geotools.api.feature.FeatureVisitor;
import org.geotools.api.feature.simple.SimpleFeature;
import org.geotools.api.feature.simple.SimpleFeatureType;
import org.geotools.api.feature.type.FeatureType;
import org.geotools.api.referencing.crs.CoordinateReferenceSystem;
import org.geotools.api.referencing.operation.MathTransform;
import org.geotools.api.style.Style;
import org.geotools.api.util.ProgressListener;
import org.geotools.data.DefaultTransaction;
import org.geotools.data.shapefile.ShapefileDataStoreFactory;
import org.geotools.data.simple.SimpleFeatureCollection;
import org.geotools.data.simple.SimpleFeatureIterator;
import org.geotools.feature.simple.SimpleFeatureTypeBuilder;
import org.geotools.geometry.jts.JTS;
import org.geotools.map.FeatureLayer;
import org.geotools.map.Layer;
import org.geotools.map.MapContent;
import org.geotools.referencing.CRS;
import org.geotools.styling.SLD;
import org.geotools.swing.JMapFrame;
import org.geotools.swing.JProgressWindow;
import org.geotools.swing.action.SafeAction;
import org.geotools.swing.data.JFileDataStoreChooser;
import org.locationtech.jts.geom.Geometry;

/** 本示例直观演示如何改变要素图层的坐标参考系统(CRS). */
public class CRSLab {

    private File sourceFile;
    private SimpleFeatureSource featureSource;
    private MapContent map;

    public static void main(String[] args) throws Exception {
        CRSLab lab = new CRSLab();
        lab.displayShapefile();
    }
```

3. 请注意，我们正在对JMapFrame进行定制化改造，主要是在工具栏添加了两个功能按钮：第一个按钮用于校验要素几何图形的有效性（例如检查多边形边界是否闭合），第二个按钮则用于导出经过重投影处理的要素数据。
```java
private void displayShapefile() throws Exception {
    // 弹出文件选择对话框，让用户选择要打开的Shapefile文件
    sourceFile = JFileDataStoreChooser.showOpenFile("shp", null);
    if (sourceFile == null) {
        return; // 如果用户取消选择，则直接返回
    }
    
    // 获取数据存储并读取要素源
    FileDataStore store = FileDataStoreFinder.getDataStore(sourceFile);
    featureSource = store.getFeatureSource();

    // 创建地图内容容器，并将Shapefile图层添加到其中
    map = new MapContent();
    // 为要素创建简单样式
    Style style = SLD.createSimpleStyle(featureSource.getSchema());
    Layer layer = new FeatureLayer(featureSource, style);
    map.layers().add(layer);

    // 创建带有自定义工具栏按钮的地图框架
    JMapFrame mapFrame = new JMapFrame(map);
    // 启用工具栏和状态栏
    mapFrame.enableToolBar(true);
    mapFrame.enableStatusBar(true);

    // 获取工具栏并添加自定义按钮
    JToolBar toolbar = mapFrame.getToolBar();
    toolbar.addSeparator(); // 添加分隔线
    // 添加"验证几何"按钮
    toolbar.add(new JButton(new ValidateGeometryAction()));
    // 添加"导出Shapefile"按钮
    toolbar.add(new JButton(new ExportShapefileAction()));

    // 显示地图框架。当窗口关闭时，应用程序将退出
    mapFrame.setSize(800, 600); // 设置窗口大小
    mapFrame.setVisible(true); // 显示窗口
}
```

4. 我们是这样配置JMapFrame的：
- 启用了状态栏功能，其中包含一个可切换地图坐标参考系统(CRS)的按钮
- 启用了工具栏并在其中添加了两个功能操作项（这些操作项的具体实现将在下一节定义）

### **几何有效性验证**
本工具栏操作采用嵌套类结构实现，核心校验逻辑由父类的辅助方法完成。

1. 几何校验操作实现（内部类）
```java
/** 
 * 功能说明：
 * 1. 继承SafeAction实现线程安全操作
 * 2. 执行要素几何有效性校验
 * 3. 弹窗显示校验结果
 */
class ValidateGeometryAction extends SafeAction {
    ValidateGeometryAction() {
        super("几何校验");
        putValue(Action.SHORT_DESCRIPTION, "检查每个几何体的有效性"); 
    }

    public void action(ActionEvent e) throws Throwable {
        // 执行几何校验并获取无效几何数量
        int numInvalid = validateFeatureGeometry(null);
        
        // 构造结果消息
        String msg = (numInvalid == 0) ? 
            "所有要素几何体均有效" : 
            "无效几何体数量: " + numInvalid;
            
        // 显示校验结果对话框
        JOptionPane.showMessageDialog(
            null, 
            msg, 
            "几何校验结果", 
            JOptionPane.INFORMATION_MESSAGE
        );
    }
}
```

2. 该方法会检查Shapefile中每个要素关联的几何图形是否存在常见问题（例如多边形边界未闭合等拓扑错误）。
```java
/**
 * 验证要素几何有效性
 * @param progress 进度监听器（可为null）
 * @return 无效几何的数量
 */
private int validateFeatureGeometry(ProgressListener progress) throws Exception {
    // 获取要素集合
    final SimpleFeatureCollection featureCollection = featureSource.getFeatures();

    /**
     * 创建要素访问器(FeatureVisitor)来校验每个要素
     * （相比迭代器方式更高效）
     */
    class ValidationVisitor implements FeatureVisitor {
        // 无效几何计数器
        public int numInvalidGeometries = 0;

        /**
         * 校验单个要素的几何体
         * @param f 待检查的要素
         */
        public void visit(Feature f) {
            SimpleFeature feature = (SimpleFeature) f;
            Geometry geom = (Geometry) feature.getDefaultGeometry();
            
            // 当几何体存在且无效时记录
            if (geom != null && !geom.isValid()) {
                numInvalidGeometries++;
                System.out.println("无效几何体ID: " + feature.getID());
            }
        }
    }

    // 实例化访问器
    ValidationVisitor visitor = new ValidationVisitor();

    /**
     * 执行批量校验：
     * 1. 将访问器应用到要素集合
     * 2. 支持进度条监控（progress参数）
     */
    featureCollection.accepts(visitor, progress);
    
    return visitor.numInvalidGeometries;
}
```

### 导出重新投影的 shapefile

以下实现一个实用工具功能，该工具可以读取原始Shapefile文件，并将其转换为指定坐标参考系统(CRS)后输出新的Shapefile文件。

本实验需要掌握的一个重要要点是：在两个CoordinateReferenceSystem（坐标参考系）之间创建MathTransform（数学转换）非常简单。您可以使用MathTransform逐个转换点坐标，或者通过JTS工具类创建经过坐标修改后的Geometry副本。

本操作采用与CSV2SHAPE示例相似的步骤导出Shapefile。具体流程为：通过FeatureIterator读取现有Shapefile内容，并使用FeatureWriter逐个写出要素。请注意使用后关闭这些对象。

1. 该操作以嵌套类形式实现，具体处理逻辑委托给父类的`exportToShapefile`方法完成。
```java
    class ExportShapefileAction extends SafeAction {
        ExportShapefileAction() {
            super("Export...");
            putValue(Action.SHORT_DESCRIPTION, "Export using current crs");
        }

        public void action(ActionEvent e) throws Throwable {
            exportToShapefile();
        }
    }
```

2. 导出重投影数据到一个shapefile：
```java
    private void exportToShapefile() throws Exception {
        SimpleFeatureType schema = featureSource.getSchema();
        JFileDataStoreChooser chooser = new JFileDataStoreChooser("shp");
        chooser.setDialogTitle("Save reprojected shapefile");
        chooser.setSaveFile(sourceFile);
        int returnVal = chooser.showSaveDialog(null);
        if (returnVal != JFileDataStoreChooser.APPROVE_OPTION) {
            return;
        }
        File file = chooser.getSelectedFile();
        if (file.equals(sourceFile)) {
            JOptionPane.showMessageDialog(null, "Cannot replace " + file);
            return;
        }
```

3. 创建 math transform 来处理数据
```java
        CoordinateReferenceSystem dataCRS = schema.getCoordinateReferenceSystem();
        CoordinateReferenceSystem worldCRS = map.getCoordinateReferenceSystem();
        boolean lenient = true; // allow for some error due to different datums
        MathTransform transform = CRS.findMathTransform(dataCRS, worldCRS, lenient);
```

4. 获取所有要素：
```java
SimpleFeatureCollection featureCollection = featureSource.getFeatures();
```

5. 创建新Shapefile需要定义一个与原始结构相似但坐标系不同的要素类型：
```java
DataStoreFactorySpi factory = new ShapefileDataStoreFactory();
Map<String, Serializable> create = new HashMap<>();
create.put("url", file.toURI().toURL());
create.put("create spatial index", Boolean.TRUE); // 创建空间索引
DataStore dataStore = factory.createNewDataStore(create);
SimpleFeatureType featureType = SimpleFeatureTypeBuilder.retype(schema, worldCRS); // 重设坐标系
dataStore.createSchema(featureType);

// 获取新建Shapefile的名称（用于开启FeatureWriter）
String createdName = dataStore.getTypeNames()[0];
```

6. 现在我们可以安全地开启迭代器遍历要素内容，并使用写入器输出新的Shapefile文件。
```java
// 创建要素读取迭代器
FeatureIterator<SimpleFeature> iterator = featureCollection.features();

// 初始化Shapefile写入器
FeatureWriter<SimpleFeatureType, SimpleFeature> writer = 
    dataStore.getFeatureWriterAppend(createdName, Transaction.AUTO_COMMIT);

try {
    while (iterator.hasNext()) {
        SimpleFeature feature = iterator.next();
        SimpleFeature newFeature = writer.next();
        // 执行要素写入操作...
        newFeature.setAttributes(feature.getAttributes());
        writer.write();
    }
} finally {
    iterator.close(); // 确保关闭迭代器
    writer.close();   // 确保关闭写入器
}
```