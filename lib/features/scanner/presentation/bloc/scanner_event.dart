part of 'scanner_bloc.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();
  @override
  List<Object?> get props => [];
}

class ScanCompleted extends ScannerEvent {
  final ScanEntity scan;
  const ScanCompleted(this.scan);
  @override
  List<Object?> get props => [scan];
}

class LoadScanHistory extends ScannerEvent {
  final String? userId;
  const LoadScanHistory({this.userId});
  @override
  List<Object?> get props => [userId];
}
