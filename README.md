# Mahout中kmeans程序, 2016秋

### 作者: 黎思言

## 1. 用命令行实现

### 1.1 搭建单机环境

#### 1.1.1 安装java和JDK

因为mahout是基于java的，所以要使用mahout，首先要在本机上下载java和java的开发者套件JDK，从官网上下载和安装好最新的java和JDK之后，我们应该修改环境变量，在环境变量中添加 JAVA_HOME 路径。添加的步骤：

```
vi ~/.bash_profile
```

然后在其中添加语句：

```
JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_111.jdk/Contents/Home"
```

语句中的路径是本机上JDK的Home路径。修改保存之后重启终端行。运行以下命令：

```
$JAVA_HOME/bin/java -version
```

如果能显示正确的java版本信息，说明修改过程无误。

#### 1.1.2 下载mahout

从mahout官网中下载mahout最新的发型版本，按照官网的提示解压文件，设置环境变量。设置环境变量的过程：

```
vi ~/.bash_profile
```

然后在其中添加语句：

```
export PATH="/Users/Lisiyan/apache-mahout-distribution-0.12.2/bin:$PATH"
export MAHOUT_HOME="/Users/Lisiyan/apache-mahout-distribution-0.12.2"
export MAHOUT_LOCAL=true
```

语句中的路径是本机上mahout的路径。保存后重启终端，在终端中输入：

```
$MAHOUT_HOME/bin/mahout
```

不报错说明单机环境设置成功。（tips：如果报错应该回头检查JAVA_HOME设置是否有错。）

### 1.2 使用命令行实现聚类

#### 1.2.1 数据说明

在本例中，我使用的数据是我从亚马逊中抓取的书评数据 bookreview，bookreview 文件夹中包含1631个文件，每一个文件里面是一条评论。使用UTF-8编码。数据已经通过了预处理，剔除了网页、标点符号、数字等无关信息。数据中的大写字母全部转换成了小写字母，数据中的词语已经通过词干化，数据中的词语已经剔除了英文停用词。数据可以从github链接中下载：https://github.com/siyanli6315/mahout-kmeans

#### 1.2.2 转换数据存储形式

mahout 能处理的数据交换格式是 SequenceFile 格式。mahout 中提供了 mahout seqdirectory 将文件转换成 SequenceFile 交换格式。代码如下：

```
mahout seqdirectory -i file://$(pwd)/bookreview \
	-o file://$(pwd)/bookreview_seq \
	-c UTF-8 -chunk 64 -xm sequential
```

通过以上命令，我们就在工作目录下生成了 bookreview_seq 文件夹。如果要查看文件夹中的内容，可以使用 mahout seqdumper 查看。代码如下：

```
mahout seqdumper -i file://$(pwd)/bookreview_seq
```

通过以上代码，我们可以看到已经转换成 <key, value> 形式的文本文件。部分输出如下：

```
Key: /997.txt: Value:  read    tri  better understand   person  may   presidenti nomine   cultur  support
Key: /998.txt: Value: good book
Key: /999.txt: Value: servic  great  book even better
Count: 1632
```

#### 1.2.3 将文本数据向量化

文本数据聚类分析要先进行向量化才可以进行进一步的处理。mahout 提供 seq2sparse 函数将文本信息向量化。代码如下：

```
mahout seq2sparse -i file://$(pwd)/bookreview_seq \
	-o file://$(pwd)/bookreview_sparse \
	-ow --weight tfidf --maxDFPercent 85 --namedVector
```

通过以上命令，我们在当前目录下生成了 bookreview_sparse 文件夹，如果要查看文件夹中的内容，应使用 mahout vectordump 函数查看。代码如下：

```
mahout vectordump -i file://$(pwd)/bookreview_sparse/tfidf-vectors
```

部分输出如下，可见我们已经将文本转换成了向量形式。

```
{883:2.4389214515686035,37:6.597804546356201}
{1171:3.1584553718566895,233:1.6974802017211914}
{2135:4.778645992279053,1562:4.806045055389404,1498:3.569282293319702,2011:5.445125102996826,195:4.085498809814453,1652:1.9826840162277222,1256:4.651894569396973,480:6.780126094818115,2161:3.9352166652679443}
{870:2.8250434398651123,233:1.6974802017211914}
{233:1.6974802017211914,195:4.085498809814453,1820:6.1923394203186035,883:2.4389214515686035,681:3.8677754402160645}
```

#### 1.2.4 kmeans聚类

数据处理好后，我们运行mahout中的kmeans函数做聚类分析。

```
mahout kmeans -i file://$(pwd)/bookreview_sparse/tfidf-vectors \
	-c file://$(pwd)/bookreview_kmeans_clusters \
	-o file://$(pwd)/bookreview_kmeans \
	-k 3 -dm \
	org.apache.mahout.common.distance.CosineDistanceMeasure \
	-x 200 -ow --clustering
```

从代码中可见，我们将所有的文本聚成3类，距离的计算方法是cosine距离法。聚类的结果保存在 bookreview_kmeans 文件夹下，初始化的聚类方式保存在 bookreview_kmeans_clusters 文件夹下。如果要查看聚类的结果，应使用 mahout seqdumper 查看聚类结果。

```
mahout seqdumper -i file://$(pwd)/bookreview_kmeans/clusteredPoints
```

部分输出如下：

```
Key: 998: Value: wt: 1.0 distance: 0.7685492695024443  vec: [{"233":1.697},{"1171":3.158}]
Key: 949: Value: wt: 1.0 distance: 0.8164580879136696  vec: [{"195":4.085},{"480":6.78},{"1256":4.652},{"1498":3.569},{"1562":4.806},{"1652":1.983},{"2011":5.445},{"2135":4.779},{"2161":3.935}]
Key: 293: Value: wt: 1.0 distance: 0.7484946225282283  vec: [{"233":1.697},{"870":2.825}]
Key: 293: Value: wt: 1.0 distance: 0.7497065769970205  vec: [{"195":4.085},{"233":1.697},{"681":3.868},{"883":2.439},{"1820":6.192}]
Count: 1619
```

每一行表示一条数据，key值表示聚类中心，三个聚类中心分别是293，949和998。有时候我们要将输出的结果用csc或者txt的形式保存起来，方便后续的研究分析。mahout seqdumper 支持按格式保存。使用 mahout seqdumper -h 可以查看帮助文档，帮助文档中详细说明了如何将 mahout 的数据导出称csc，json或者txt.

代码和数据可以从github链接中下载：https://github.com/siyanli6315/mahout-kmeans

## 2. 用maven实现

### 2.1 搭建单机环境

Mahout是Apache的一个开源项目，提供了机器学习领域的若干经典算法，以便开发人员快速构建机器学习和数据挖掘方面的应用。Mahout可以在单机上运行也可以在hadoop集群上运行。在本文中，我详细介绍一下如何在本机上搭建一个mahout开发环境。

#### 2.1.1 安装eclipse

eclipse是一个java的IDE。mahout是基于java的，使用eclipse会比较方便。eclipse 直接从官网上下载并安装即可。

#### 2.1.2 安装maven

Maven是一个java的包管理和储存工具。在我的mac上，有两种方式可以安装maven，第一种方式是从官网下载maven解压，然后根据官方文档修改环境变量。第二种方法是使用mac的命令行工具 brew install maven 安装。推荐使用后一种方法。安装完成后，运行以下命令：

```
mvn -v
```

如果能正确显示maven的版本信息，且版本大于等于3，说明安装过程无误。如果安装过程出错，很有可能是 JAVA_HOME 目录出错。

#### 2.1.3 安装m2eclipse

m2eclipse 是一个 eclipse 插件，用来连接 eclipse 和 maven，方便在 eclipse中创建 maven 类型的项目。eclipse 一般是自带 m2eclipse 插件的，如果没有，加载方式是：

菜单栏点击 help > install new software 输入 m2v - http://www.eclipse.org/m2e/download/ > finish

### 2.2 构建mahout项目

### 2.2.1 新建maven project

在eclipse中构建一个maven项目 构建的方式是 file > new > project > maven project 后面的构建方法全部使用默认选项即可。如果构建成功的话，我们可以在工作目录下找到我们刚刚创建的文件，同时我们也可以在 eclipse 的 project Explorer 窗口下找到创建的文件。

#### 2.2.2 添加依赖包

有了maven项目，我们还不能编写mahout程序，还必须在maven中添加我们程序所依赖的包。maven提供了很方便的借口帮助我们从其他文件中或者从互联网中导入包。导入包的方法是：在刚刚创建的project的根目录下，双击pom.xml，在右边的面板中选择Dependencies，点击Add，在弹出的对话框中输入mahout，Maven便会搜索相关包，选择mahout-core，确定。有时候受限于网络环境，maven将花很长的时间搜索包，这时候我们可以双击porm.xml，在右边的面板中选择porm.xml，然后在 <dependencies> 中加上以下代码：

```
  <dependency>
    	<groupId>org.apache.mahout</groupId>
    	<artifactId>mahout-core</artifactId>
    	<version>0.9</version>
    	<type>jar</type>
    	<scope>compile</scope>
    </dependency>
```

上述代码帮助我们手动添加了0.9版本的mahout-core代码。然后右键点击我们刚刚创建的项目 > maven > updata project。第一次进行这个过程会比较长，因为maven将从网站上下载mahout-core所有的jar程序。如果成功运行了，接下来我们就可以使用mahout中几乎所有的函数类了。

### 2.3 使用mahout构建聚类函数

通过上述过程，我们已经搭建了一个maven项目，并在maven项目中导入了所依赖的mahout包，接下来，我们就要在这个项目中写一个kmeans函数。双击 project explorer 菜单栏下 src/main/java/APP.java 文件可以进入编辑模式。

本文的代码参考网站为 http://technobium.com/introduction-to-clustering-using-apache-mahout/

```java
  package mahout.kmeans1;

import java.io.IOException;
import java.util.List;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.SequenceFile;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.Writable;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.mahout.clustering.canopy.CanopyDriver;
import org.apache.mahout.clustering.fuzzykmeans.FuzzyKMeansDriver;
import org.apache.mahout.common.Pair;
import org.apache.mahout.common.distance.EuclideanDistanceMeasure;
import org.apache.mahout.common.iterator.sequencefile.SequenceFileIterable;
import org.apache.mahout.vectorizer.DictionaryVectorizer;
import org.apache.mahout.vectorizer.DocumentProcessor;
import org.apache.mahout.vectorizer.common.PartialVectorMerger;
import org.apache.mahout.vectorizer.tfidf.TFIDFConverter;

public class App {

    String outputFolder;
    Configuration configuration;
    FileSystem fileSystem;
    Path documentsSequencePath;
    Path tokenizedDocumentsPath;
    Path tfidfPath;
    Path termFrequencyVectorsPath;

    public static void main(String args[]) throws Exception {
        App tester = new App();

        tester.createTestDocuments();
        tester.calculateTfIdf();
        tester.clusterDocs();

        tester.printSequenceFile(tester.documentsSequencePath);

        System.out.println("\n Clusters: ");
        tester.printSequenceFile(new Path(tester.outputFolder
                + "clusters/clusteredPoints/part-m-00000"));
    }

    public App() throws IOException {
        configuration = new Configuration();
        fileSystem = FileSystem.get(configuration);

        outputFolder = "output/";
        documentsSequencePath = new Path(outputFolder, "sequence");
        tokenizedDocumentsPath = new Path(outputFolder,
                DocumentProcessor.TOKENIZED_DOCUMENT_OUTPUT_FOLDER);
        tfidfPath = new Path(outputFolder + "tfidf");
        termFrequencyVectorsPath = new Path(outputFolder
                + DictionaryVectorizer.DOCUMENT_VECTOR_OUTPUT_FOLDER);
    }

    public void createTestDocuments() throws IOException {
        SequenceFile.Writer writer = new SequenceFile.Writer(fileSystem,
                configuration, documentsSequencePath, Text.class, Text.class);

        Text id1 = new Text("Document 1");
        Text text1 = new Text("John saw a red car.");
        writer.append(id1, text1);

        Text id2 = new Text("Document 2");
        Text text2 = new Text("Marta found a red bike.");
        writer.append(id2, text2);

        Text id3 = new Text("Document 3");
        Text text3 = new Text("Don need a blue coat.");
        writer.append(id3, text3);

        Text id4 = new Text("Document 4");
        Text text4 = new Text("Mike bought a blue boat.");
        writer.append(id4, text4);

        Text id5 = new Text("Document 5");
        Text text5 = new Text("Albert wants a blue dish.");
        writer.append(id5, text5);

        Text id6 = new Text("Document 6");
        Text text6 = new Text("Lara likes blue glasses.");
        writer.append(id6, text6);

        Text id7 = new Text("Document 7");
        Text text7 = new Text("Donna, do you have red apples?");
        writer.append(id7, text7);

        Text id8 = new Text("Document 8");
        Text text8 = new Text("Sonia needs blue books.");
        writer.append(id8, text8);

        Text id9 = new Text("Document 9");
        Text text9 = new Text("I like blue eyes.");
        writer.append(id9, text9);

        Text id10 = new Text("Document 10");
        Text text10 = new Text("Arleen has a red carpet.");
        writer.append(id10, text10);

        writer.close();
    }

    public void calculateTfIdf() throws ClassNotFoundException, IOException,
            InterruptedException {
        DocumentProcessor.tokenizeDocuments(documentsSequencePath,
                StandardAnalyzer.class, tokenizedDocumentsPath, configuration);

        DictionaryVectorizer.createTermFrequencyVectors(tokenizedDocumentsPath,
                new Path(outputFolder),
                DictionaryVectorizer.DOCUMENT_VECTOR_OUTPUT_FOLDER,
                configuration, 1, 1, 0.0f, PartialVectorMerger.NO_NORMALIZING,
                true, 1, 100, false, false);

        Pair<Long[], List<Path>> documentFrequencies = TFIDFConverter
                .calculateDF(termFrequencyVectorsPath, tfidfPath,
                        configuration, 100);

        TFIDFConverter.processTfIdf(termFrequencyVectorsPath, tfidfPath,
                configuration, documentFrequencies, 1, 100,
                PartialVectorMerger.NO_NORMALIZING, false, false, false, 1);
    }

    void clusterDocs() throws ClassNotFoundException, IOException,
            InterruptedException {
        String vectorsFolder = outputFolder + "tfidf/tfidf-vectors/";
        String canopyCentroids = outputFolder + "canopy-centroids";
        String clusterOutput = outputFolder + "clusters";

        FileSystem fs = FileSystem.get(configuration);
        Path oldClusterPath = new Path(clusterOutput);

        if (fs.exists(oldClusterPath)) {
            fs.delete(oldClusterPath, true);
        }

        CanopyDriver.run(new Path(vectorsFolder), new Path(canopyCentroids),
                new EuclideanDistanceMeasure(), 20, 5, true, 0, true);

        FuzzyKMeansDriver.run(new Path(vectorsFolder), new Path(
                canopyCentroids, "clusters-0-final"), new Path(clusterOutput),
                0.01, 20, 2, true, true, 0, false);
    }

    void printSequenceFile(Path path) {
        SequenceFileIterable<Writable, Writable> iterable = new SequenceFileIterable<Writable, Writable>(
                path, configuration);
        for (Pair<Writable, Writable> pair : iterable) {
            System.out
                    .format("%10s -> %s\n", pair.getFirst(), pair.getSecond());
        }
    }
}
```

右键点击创建的项目，选择 run as > 1 java application 在命令行中看到如下输出：

```
Document 1 -> John saw a red car.
Document 2 -> Marta found a red bike.
Document 3 -> Don need a blue coat.
Document 4 -> Mike bought a blue boat.
Document 5 -> Albert wants a blue dish.
Document 6 -> Lara likes blue glasses.
Document 7 -> Donna, do you have red apples?
Document 8 -> Sonia needs blue books.
Document 9 -> I like blue eyes.
Document 10 -> Arleen has a red carpet.

 Clusters:
         7 -> wt: 1.0 distance: 4.4960791719810365  vec: Document 1 = [8:2.609, 21:2.609, 29:1.693, 30:2.609]
         7 -> wt: 1.0 distance: 4.496079376645949  vec: Document 10 = [2:2.609, 9:2.609, 18:2.609, 29:1.693]
         7 -> wt: 1.0 distance: 4.496079576525459  vec: Document 2 = [3:2.609, 16:2.609, 25:2.609, 29:1.693]
         9 -> wt: 1.0 distance: 4.389955960700927  vec: Document 3 = [4:1.357, 10:2.609, 13:2.609, 27:2.609]
         9 -> wt: 1.0 distance: 4.389956011306051  vec: Document 4 = [4:1.357, 5:2.609, 7:2.609, 26:2.609]
         9 -> wt: 1.0 distance: 4.3899560687101395  vec: Document 5 = [0:2.609, 4:1.357, 11:2.609, 32:2.609]
         9 -> wt: 1.0 distance: 4.389956137136399  vec: Document 6 = [4:1.357, 17:2.609, 22:2.609, 24:2.609]
         7 -> wt: 1.0 distance: 5.577549042707083  vec: Document 7 = [1:2.609, 12:2.609, 14:2.609, 19:2.609, 29:1.693, 33:2.609]
         9 -> wt: 1.0 distance: 4.389956708176695  vec: Document 8 = [4:1.357, 6:2.609, 28:2.609, 31:2.609]
         9 -> wt: 1.0 distance: 4.389471924190491  vec: Document 9 = [4:1.357, 15:2.609, 20:2.609, 23:2.609]
```

输出的结果显示，我们将文本1，10，2，7归位聚类为第一类，将其余的句子聚类为第二类。而且我们还能观察到，我们将句中带有red的归位同一类，而将blue归位另一类。
