import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:reconhecimento/widgets/modals.dart';
class relacaoPontoPage extends StatefulWidget {
  final String matricula;
  final String cnpj;

  const relacaoPontoPage({
    required this.matricula,
    required this.cnpj,
    super.key,
  });

  @override
  _RelacaoPontoColaboradorState createState() => _RelacaoPontoColaboradorState();
}

// Classe do State (privada, com _ no início)
class _RelacaoPontoColaboradorState extends State<relacaoPontoPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendário de Ponto',
          style: TextStyle(color: Colors.black), // Texto preto
        ),
        backgroundColor: Color.fromARGB(255, 215, 221, 231), // Fundo branco
        iconTheme: IconThemeData(color: Colors.black), // Ícones pretos
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              defaultTextStyle: TextStyle(color: Colors.black), // Texto padrão preto
              weekendTextStyle: TextStyle(color: Colors.black), // Finais de semana pretos
              selectedTextStyle: TextStyle(color: Colors.white), // Texto do dia selecionado branco
              todayTextStyle: TextStyle(color: Colors.white), // Texto do dia atual branco
              todayDecoration: BoxDecoration(
                color: Colors.blue, // Dia atual com fundo azul
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.black, // Dia selecionado com fundo preto
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleTextStyle: TextStyle(color: Colors.black), // Texto do título preto
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black), // Ícones pretos
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
            ),
          ),
          Divider(color: Colors.black),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Inserções de ponto: ",
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "08:00 | 10:15 | 11:15 | 18:00 ",
                        style: GoogleFonts.roboto(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      "Horas previstas: ",
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "08 HR",
                        style: GoogleFonts.roboto(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  justificativaModal(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 3, 33, 255), // Fundo preto
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Incluir Ponto',
                  style: GoogleFonts.roboto(
                    color: Colors.white, // Texto branco para contraste
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 215, 221, 231), // Fundo branco
    );
  }

}
