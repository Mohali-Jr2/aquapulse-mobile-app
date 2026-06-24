class ValveModel {
  final String meterCode;
  final bool valveOpen;

  ValveModel({
    required this.meterCode,
    required this.valveOpen,
  });

  factory ValveModel.fromJson(Map<String, dynamic> json) {
    return ValveModel(
      meterCode: json['meter_code'],
      valveOpen: json['valve_open'] == true,
    );
  }
}