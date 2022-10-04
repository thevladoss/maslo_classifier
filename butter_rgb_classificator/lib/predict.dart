// Use KnnClassifier from ml_algo package
// https://pub.dev/packages/ml_algo

import 'dart:io';

import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';

import 'pca.dart';

class ButterClassifier {
  late final KnnClassifier _classifier;
  late final PCAButter _pca;
  final Map<int, String> labelTable;

  ButterClassifier({
    String pathToCsv = 'data/butter_rgb_with_labels_numbers.csv',
    this.labelTable = const {
      0: 'сливочное',
      1: 'кокосовое',
      2: 'фальсификат',
    },
  }) {
    // Load training Data From CSV
    String csv = File(pathToCsv).readAsStringSync();

    // csv to List<List<double>>
    List<List<double>> trainingData = [];
    List<String> lines = csv.split('\n');
    bool isLabel = true;
    for (var line in lines) {
      if (isLabel) {
        isLabel = false;
        continue;
      }
      List<String> numbers = line.split(',');
      List<double> rgb = [];
      int i = 0;
      for (var number in numbers) {
        rgb.add(double.parse(number));
        i++;
        if (i == 3) {
          break;
        }
      }
      trainingData.add(rgb);
    }

    // Create PCA columns
    _pca = PCAButter();
    List<List<double>> pcaRGBData = _pca.listTransform(trainingData);

    final pca1 = pcaRGBData.map((e) => e[0]).toList();
    final pca2 = pcaRGBData.map((e) => e[1]).toList();

    DataFrame trainData = DataFrame.fromRawCsv(csv);
    trainData = trainData.dropSeries(indices: [0, 1, 2]);

    trainData = trainData.addSeries(Series('pca1', pca1));
    trainData = trainData.addSeries(Series('pca2', pca2));

    // print("trainData $trainData");

    // Initialize a KNN classifier
    _classifier = KnnClassifier(
      trainData,
      'cluster',
      3,
    );
  }

  // String predict(int r, int g, int b) {
  //   // Define sample data
  //   final sample = [
  //     ['pca1', 'pca2'],
  //     _pca.scaleTransform(
  //         [r.roundToDouble(), g.roundToDouble(), b.roundToDouble()])
  //   ];
  //   final df = DataFrame(sample);
  //   // print(df);
  //   // Predict cluster for sample data
  //   int idxCluster = _classifier.predict(df).rows.first.first.round();
  //   String label = labelTable[idxCluster]!;
  //   return label;
  // }
  int decisionTreeForward(double pca1, double pca2) {
    if (pca2 <= 0.07) {
      if (pca1 <= 0.656) {
        return 0;
      } else {
        return 1;
      }
    } else {
      return 2;
    }
  }

  String predict(int r, int g, int b) {
    // Predict cluster for sample data
    final lol = _pca.scaleTransform(
        [r.roundToDouble(), g.roundToDouble(), b.roundToDouble()]);
    int idxCluster = decisionTreeForward(lol[0], lol[1]);
    String label = labelTable[idxCluster]!;
    return label;
  }
}

void main() {
  print('Hello, ButterClassifier!');
  ButterClassifier butterClassifier = ButterClassifier(
    pathToCsv: 'data/butter_rgb_with_labels_numbers.csv',
    labelTable: const {
      0: 'сливочное72',
      1: 'фальсификат',
      2: 'сливочное82',
    },
  );

  // Test color means
  print(butterClassifier.predict(151, 203, 154));
  print(butterClassifier.predict(130, 217, 234));
  print(butterClassifier.predict(158, 223, 185));
}