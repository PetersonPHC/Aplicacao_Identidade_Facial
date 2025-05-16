import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:reconhecimento/controller/registro_ponto_controller.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class RelacaoPontoPage extends StatefulWidget {
  final String matricula;
  final String cnpj;

  const RelacaoPontoPage({
    required this.matricula,
    required this.cnpj,
    super.key,
  });

  @override
  _RelacaoPontoColaboradorState createState() =>
      _RelacaoPontoColaboradorState();
}

class _RelacaoPontoColaboradorState extends State<RelacaoPontoPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late RegistroPontoController _registroPontoController;
  Map<String, dynamic> _registros = {};
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _registroPontoController = RegistroPontoController(
      matricula: widget.matricula,
      cnpj: widget.cnpj,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initializeDateFormatting('pt_BR', null);
      setState(() {}); // Força a reconstrução após a inicialização
    });
  }

  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final registros = await _registroPontoController.buscarRegistrosPonto(
        cnpjEmpresa: widget.cnpj,
        matricula: widget.matricula,
        data: selectedDay,
      );

      setState(() {
        _registros = registros;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showTimePickerModal(BuildContext context) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      final formattedTime =
          "${selectedTime.hourOfPeriod}:${selectedTime.minute.toString().padLeft(2, '0')}";
      final isAm = selectedTime.period == DayPeriod.am;
      _addTimeToSelectedDay(formattedTime, isAm);
    }
  }

  Future<void> _addTimeToSelectedDay(String time, bool isAm) async {
    if (_selectedDay == null) return;

    final timeParts = time.split(':');
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Conversão de AM/PM para 24 horas
    if (isAm) {
      // AM: 12 vira 0, 1-11 permanecem
      hour = hour == 12 ? 0 : hour;
    } else {
      // PM: 12 permanece, 1-11 somam 12
      hour = hour == 12 ? 12 : hour + 12;
    }

    // Cria a data/hora diretamente em UTC
    final utcDateTime = DateTime.utc(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      hour,
      minute,
    );

    // Formata no padrão ISO 8601 com milissegundos fixos e Z (UTC)
    final formattedDate = '${utcDateTime.toIso8601String().split('.')[0]}.000Z';

    final success = await _registroPontoController.adicionarRegistroPonto(
      context: context,
      dataPonto: formattedDate,
    );

    if (success) {
      await _onDaySelected(_selectedDay!, _focusedDay);
    }
  }

  Future<void> _removeTime(BuildContext context, String time) async {
    final timeParts = time.split(':');
    if (timeParts.length < 3) {
      throw Exception("Formato de hora inválido. Esperado HH:mm:ss");
    }

    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final second = int.parse(timeParts[2]); // Extrai os segundos

    // Cria a data/hora em UTC incluindo os segundos
    final utcDateTime = DateTime.utc(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      hour,
      minute,
      second, // Inclui os segundos
    );

    // Formata no padrão ISO 8601 com milissegundos fixos e Z (UTC)
    final formattedDate = '${utcDateTime.toIso8601String().split('.')[0]}.000Z';

    final success = await _registroPontoController.removerRegistroPonto(
      context: context,
      dataPonto: formattedDate,
    );

    if (success) {
      await _onDaySelected(_selectedDay!, _focusedDay); // Atualiza a lista
    }
  }

  void justificativaModal(BuildContext context) {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecione uma data primeiro")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Adicionar registro de ponto"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.access_time),
                title: Text("Selecionar horário"),
                onTap: () {
                  Navigator.of(context).pop();
                  _showTimePickerModal(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendário de Ponto',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color.fromARGB(255, 215, 221, 231),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Seletor de mês/ano
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _focusedDay,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialEntryMode: DatePickerEntryMode.calendarOnly,
                    initialDatePickerMode: DatePickerMode.year,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Colors.blue,
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null && picked != _focusedDay) {
                    setState(() {
                      _focusedDay = picked;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat.yMMMM('pt_BR')
                            .format(_focusedDay), // Formato em português
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, size: 28),
                    ],
                  ),
                ),
              ),

              // Calendário
              TableCalendar(
                locale: 'pt_BR', // Configura o locale para português
                focusedDay: _focusedDay,
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                headerStyle: HeaderStyle(
                  titleTextFormatter: (date, locale) => '',
                  titleCentered: false,
                  formatButtonVisible: false,
                  headerPadding: EdgeInsets.zero,
                  leftChevronVisible: false,
                  rightChevronVisible: false,
                  leftChevronIcon: Icon(Icons.chevron_left, size: 28),
                  rightChevronIcon: Icon(Icons.chevron_right, size: 28),
                  headerMargin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
                availableGestures: AvailableGestures.all,
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  weekendStyle: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                  setState(() {});
                },
                calendarStyle: CalendarStyle(
                  defaultTextStyle: GoogleFonts.roboto(color: Colors.black),
                  weekendTextStyle: GoogleFonts.roboto(color: Colors.black),
                  selectedTextStyle: GoogleFonts.roboto(color: Colors.white),
                  todayTextStyle: GoogleFonts.roboto(color: Colors.white),
                  todayDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  outsideDaysVisible: false,
                  cellMargin: EdgeInsets.all(4),
                ),
                rowHeight: 40,
              ),
              Divider(color: Colors.black, thickness: 1),

              // Seção de registros (mantido igual)
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                        "Registros de ponto:",
                        _registros['pontos'] != null &&
                                _registros['pontos'].isNotEmpty
                            ? Wrap(
                                direction: Axis.horizontal,
                                spacing: 8.0,
                                children: (_registros['pontos'] as List)
                                    .map<Widget>((time) {
                                  return InputChip(
                                    label: Text(_formatTimeForDisplay(
                                        time)), // Exibe formatado
                                    onDeleted: () => _removeTime(context,
                                        time), // Passa o valor original com segundos
                                    deleteIcon: Icon(Icons.close, size: 18),
                                  );
                                }).toList(),
                              )
                            : Text(
                                "Nenhum registro encontrado",
                                style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              )),
                    SizedBox(height: 16),
                    _buildInfoRow(
                        "Horas trabalhadas:",
                        Text(
                          _registros['tempo_trabalhado'] ?? "0:00 HR",
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        )),
                    SizedBox(height: 16),
                    _buildInfoRow(
                        "Total de registros:",
                        Text(
                          _registros['total_registros']?.toString() ?? "0",
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        )),
                  ],
                ),
              ),

              // Botão de incluir ponto
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    justificativaModal(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 3, 33, 255),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Incluir Ponto',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 215, 221, 231),
    );
  }

  String _formatTimeForDisplay(String time) {
    try {
      // Converte o tempo para DateTime (assumindo formato HH:mm:ss)
      final parts = time.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}'; // Retorna apenas horas e minutos
      }
      return time; // Se não tiver o formato esperado, retorna original
    } catch (e) {
      return time; // Em caso de erro, retorna original
    }
  }

// Método auxiliar para construir linhas de informação
  Widget _buildInfoRow(String label, Widget value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 8),
        Expanded(child: value),
      ],
    );
  }
}
