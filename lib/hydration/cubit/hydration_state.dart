import 'package:equatable/equatable.dart';

abstract class HydrationState extends Equatable {
  const HydrationState();

  @override
  List<Object> get props => [];
}

class HydrationInitial extends HydrationState {}

class HydrationLoading extends HydrationState {}

class HydrationLoaded extends HydrationState {
  final int currentIntake;
  final bool hasUnsyncedData;

  const HydrationLoaded(this.currentIntake, {this.hasUnsyncedData = false});

  @override
  List<Object> get props => [currentIntake, hasUnsyncedData];
}

class HydrationError extends HydrationState {
  final String message;

  const HydrationError(this.message);

  @override
  List<Object> get props => [message];
}
