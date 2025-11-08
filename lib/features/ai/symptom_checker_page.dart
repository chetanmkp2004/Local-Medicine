import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/app_state.dart';
import '../../core/models.dart';

class SymptomCheckerPage extends StatefulWidget {
  const SymptomCheckerPage({super.key});

  @override
  State<SymptomCheckerPage> createState() => _SymptomCheckerPageState();
}

class _SymptomCheckerPageState extends State<SymptomCheckerPage>
    with TickerProviderStateMixin {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _symptomText = '';
  List<Medicine> _suggestedMedicines = [];
  bool _isLoading = false;
  late AnimationController _pulseController;
  late AnimationController _resultController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _resultAnimation;
  final TextEditingController _textController = TextEditingController();

  String _selectedLanguage = 'en'; // 'en' or 'te'

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _initializeSpeech();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _resultAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.easeOutCubic),
    );
  }

  Future<void> _initializeSpeech() async {
    try {
      await _speechToText.initialize(
        onStatus: (status) {
          debugPrint('Speech Status: $status');
          if (status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          debugPrint('Speech Error: $error');
          _showSnackbar('Microphone error: $error', 'మైక్రోఫోన్ ఎరర్: $error');
          setState(() => _isListening = false);
        },
      );
    } catch (e) {
      debugPrint('Speech init error: $e');
    }
  }

  Future<void> _startListening() async {
    if (!_speechToText.isAvailable) {
      _showSnackbar(
        'Speech recognition not available',
        'ప్రసంగ గుర్తింపు అందుబాటులో లేదు',
      );
      return;
    }

    if (!_isListening) {
      setState(() => _isListening = true);
      _pulseController.repeat(reverse: true);

      try {
        await _speechToText.listen(
          onResult: (result) {
            setState(() {
              _symptomText = result.recognizedWords;
              _textController.text = _symptomText;
            });

            if (result.finalResult) {
              _pulseController.stop();
              setState(() => _isListening = false);
              // Auto-fetch suggestions after listening completes
              Future.delayed(const Duration(milliseconds: 500), () {
                _fetchSuggestions();
              });
            }
          },
          localeId: _selectedLanguage == 'te' ? 'te_IN' : 'en_US',
        );
      } catch (e) {
        debugPrint('Listen error: $e');
        _pulseController.stop();
        setState(() => _isListening = false);
      }
    }
  }

  void _stopListening() {
    _speechToText.stop();
    _pulseController.stop();
    setState(() => _isListening = false);
  }

  Future<void> _fetchSuggestions() async {
    if (_symptomText.trim().isEmpty) {
      _showSnackbar(
        'Please enter or speak symptoms',
        'దయచేసి లక్షణాలను నమోదు చేయండి లేదా మాట్లాడండి',
      );
      return;
    }

    setState(() => _isLoading = true);
    _resultController.reset();

    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 2));

    final state = AppStateScope.of(context);
    final suggestions = _getAISuggestions(_symptomText, state.medicines);

    setState(() {
      _suggestedMedicines = suggestions;
      _isLoading = false;
    });

    _resultController.forward();
  }

  List<Medicine> _getAISuggestions(String symptoms, List<Medicine> medicines) {
    final lowerSymptoms = symptoms.toLowerCase();

    // Simple symptom-to-medicine mapping (mock AI)
    final Map<String, List<String>> symptomMap = {
      // Cold & Flu
      'cold': ['Paracetamol', 'Aspirin', 'Cough Syrup'],
      'flu': ['Oseltamivir', 'Vitamin C'],
      'cough': ['Cough Syrup', 'Dextromethorphan'],
      'fever': ['Paracetamol', 'Ibuprofen'],
      'headache': ['Ibuprofen', 'Aspirin'],
      'body ache': ['Ibuprofen', 'Paracetamol'],

      // Telugu equivalents
      'జ్వరం': ['Paracetamol', 'Ibuprofen'],
      'దగ్గు': ['Cough Syrup', 'Dextromethorphan'],
      'గుండెపోటు': ['Ibuprofen', 'Paracetamol'],
      'శీతకాటి': ['Paracetamol', 'Vitamin C'],
      'ఎక్కువ చేతిపోటు': ['Ibuprofen', 'Paracetamol'],
      'శరీర నొప్పి': ['Ibuprofen', 'Paracetamol'],

      // Digestive
      'stomach': ['Omeprazole', 'Antacid'],
      'acidity': ['Antacid', 'Omeprazole'],
      'diarrhea': ['Loperamide', 'Metronidazole'],
      'constipation': ['Laxative', 'Psyllium Husk'],

      // Telugu digestive
      'కడుపు': ['Omeprazole', 'Antacid'],
      'ఆమ్లతా': ['Antacid', 'Omeprazole'],
      'విరేచనాలు': ['Loperamide', 'Metronidazole'],
      'మలబద్ధత': ['Laxative', 'Psyllium Husk'],

      // Skin
      'rash': ['Antihistamine', 'Hydrocortisone Cream'],
      'itch': ['Antihistamine', 'Calamine Lotion'],
      'allergy': ['Antihistamine', 'Corticosteroid'],

      // Telugu skin
      'దద్దు': ['Antihistamine', 'Hydrocortisone Cream'],
      'జూజూలు': ['Antihistamine', 'Calamine Lotion'],
      'అలర్జీ': ['Antihistamine', 'Corticosteroid'],
    };

    Set<String> matchedMedicineNames = {};

    for (var entry in symptomMap.entries) {
      if (lowerSymptoms.contains(entry.key.toLowerCase())) {
        matchedMedicineNames.addAll(entry.value);
      }
    }

    // If no exact matches, return top generics
    if (matchedMedicineNames.isEmpty) {
      matchedMedicineNames = {
        'Paracetamol',
        'Ibuprofen',
        'Antihistamine',
      }.toSet();
    }

    return medicines
        .where((med) => matchedMedicineNames.contains(med.nameFor('en')))
        .take(5)
        .toList();
  }

  void _showSnackbar(String en, String te) {
    final state = AppStateScope.of(context);
    final msg = state.languageCode == 'te' ? te : en;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _speechToText.stop();
    _pulseController.dispose();
    _resultController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    String t(String en, String te) => state.languageCode == 'te' ? te : en;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                t('AI Symptom Checker', 'AI లక్షణ చెకర్'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(
                        Icons.health_and_safety_outlined,
                        size: 120,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width > 600 ? 24.0 : 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Language Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t('Language', 'భాష'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            _LanguageButton(
                              label: 'English',
                              isSelected: _selectedLanguage == 'en',
                              onTap: () {
                                setState(() => _selectedLanguage = 'en');
                              },
                            ),
                            _LanguageButton(
                              label: 'తెలుగు',
                              isSelected: _selectedLanguage == 'te',
                              onTap: () {
                                setState(() => _selectedLanguage = 'te');
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Speech/Text Input Section
                  Text(
                    t('Describe Your Symptoms', 'మీ లక్షణాలను వివరించండి'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Text Input Field
                  TextField(
                    controller: _textController,
                    minLines: 3,
                    maxLines: 5,
                    readOnly: _isListening,
                    decoration: InputDecoration(
                      hintText: t(
                        'Type or speak your symptoms here...',
                        'ఇక్కడ మీ లక్షణాలను టైప్ చేయండి లేదా మాట్లాడండి...',
                      ),
                      prefixIcon: const Icon(Icons.edit_note_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _symptomText = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Voice Input Button
                  if (!_isListening)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _startListening,
                        icon: const Icon(Icons.mic_rounded),
                        label: Text(
                          t('Start Speaking', 'మాట్లాడటం ప్రారంభించండి'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withOpacity(0.2),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.mic,
                              size: 40,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _symptomText.isEmpty
                              ? t('Listening...', 'వింటోంది...')
                              : _symptomText,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _stopListening,
                            icon: const Icon(Icons.stop_rounded),
                            label: Text(t('Stop', 'ఆపండి')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // Search Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _fetchSuggestions,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.search_rounded),
                      label: Text(
                        t(
                          _isLoading
                              ? 'Analyzing...'
                              : 'Get Medicine Suggestions',
                          _isLoading
                              ? 'విశ్లేషిస్తోంది...'
                              : 'ఔషధ సూచనలు పొందండి',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Results Section
                  if (_suggestedMedicines.isNotEmpty)
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(_resultAnimation),
                      child: FadeTransition(
                        opacity: _resultAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.green,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  t('Suggested Medicines', 'సూచించిన ఔషధాలు'),
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ..._suggestedMedicines.asMap().entries.map((e) {
                              final idx = e.key;
                              final med = e.value;
                              return TweenAnimationBuilder<double>(
                                duration: Duration(
                                  milliseconds: 300 + (idx * 100),
                                ),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: _MedicineCard(
                                  medicine: med,
                                  onViewMore: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${med.nameFor(state.languageCode)} - ${"More details coming soon"}',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onViewMore;

  const _MedicineCard({required this.medicine, required this.onViewMore});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.medication_rounded,
                color: Colors.blue,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.nameFor(state.languageCode),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Over the counter',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              onPressed: onViewMore,
            ),
          ],
        ),
      ),
    );
  }
}
