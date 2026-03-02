part of 'scanner_bloc.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();
  @override
  List<Object?> get props => [];
}

class ScannerInitial extends ScannerState {}

class ScannerLoading extends ScannerState {}

class ScanSuccess extends ScannerState {
  final ScanEntity scan;
  const ScanSuccess(this.scan);
  @override
  List<Object?> get props => [scan];
}

class ScanHistoryLoaded extends ScannerState {
  final List<ScanEntity> history;
  const ScanHistoryLoaded(this.history);
  @override
  List<Object?> get props => [history];
}

class ScannerError extends ScannerState {
  final String message;
  const ScannerError(this.message);
  @override
  List<Object?> get props => [message];
}
