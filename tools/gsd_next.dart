#!/usr/bin/env dart
import 'dart:io';

final roadmapPath = '.planning/ROADMAP.md';
final phasesDir = Directory('.planning/phases');
final statePath = '.planning/STATE.md';

List<int> parsePhasesFromRoadmap(String content) {
  final reg = RegExp(r'### Phase\s*(\d+)');
  final matches = reg.allMatches(content);
  return matches.map((m) => int.parse(m.group(1)!)).toList();
}

String normalizePhaseDirName(int n, List<String> dirs) {
  // find dir that starts with two-digit or number and dash
  final prefix = n.toString().padLeft(2, '0');
  for (final d in dirs) {
    final name = d.split(Platform.pathSeparator).last;
    if (name.startsWith('$n-') || name.startsWith(prefix)) return d;
    if (name.startsWith('$n')) return d;
  }
  return '${n.toString().padLeft(2, '0')}-${n.toString()}';
}

Map<String, dynamic> analyzePhaseDir(Directory dir) {
  final res = <String, dynamic>{};
  final plan = File('${dir.path}/04-01-PLAN.md');
  // generic check: any PLAN.md in dir
  final plans = dir.listSync().whereType<File>().where((f) => f.path.endsWith('-PLAN.md')).toList();
  res['hasPlan'] = plans.isNotEmpty;
  res['plans'] = plans.map((f) => f.path).toList();
  final summary = dir.listSync().whereType<File>().where((f) => f.path.endsWith('-SUMMARY.md')).toList();
  res['hasSummary'] = summary.isNotEmpty;
  final verification = File('${dir.path}/VERIFICATION.md');
  if (verification.existsSync()) {
    final c = verification.readAsStringSync();
    if (c.contains('Status: PASS')) res['verification'] = 'PASS';
    else if (c.contains('Status: FAIL')) res['verification'] = 'FAIL';
    else res['verification'] = 'UNKNOWN';
  } else {
    res['verification'] = 'MISSING';
  }
  final research = File('${dir.path}/RESEARCH.md');
  res['hasResearch'] = research.existsSync();
  return res;
}

void main(List<String> args) {
  final force = args.contains('--force');

  if (!File(roadmapPath).existsSync()) {
    stderr.writeln('ERROR: ROADMAP.md not found at $roadmapPath');
    exit(2);
  }

  final roadmap = File(roadmapPath).readAsStringSync();
  final phases = parsePhasesFromRoadmap(roadmap);
  if (phases.isEmpty) {
    stdout.writeln('No phases found in ROADMAP.md');
    exit(0);
  }

  stdout.writeln('Detected roadmap phases: ${phases.join(', ')}');

  final dirs = <String>[];
  if (phasesDir.existsSync()) {
    for (final e in phasesDir.listSync()) {
      if (e is Directory) dirs.add(e.path);
    }
  }

  final issues = <Map<String, dynamic>>[];
  for (final p in phases) {
    final dir = dirs.firstWhere((d) => d.contains(p.toString().padLeft(2, '0')) || d.contains(p.toString()), orElse: () => '');
    if (dir.isEmpty) {
      // phase directory missing => mark unplanned
      issues.add({'phase': p, 'issue': 'unplanned'});
      break; // next logical step is to plan this phase
    }
    final analysis = analyzePhaseDir(Directory(dir));
    if (analysis['hasPlan'] == true && analysis['hasSummary'] == false) {
      issues.add({'phase': p, 'issue': 'plan_without_summary', 'details': analysis});
      break;
    }
    if (analysis['verification'] == 'FAIL') {
      issues.add({'phase': p, 'issue': 'verification_failed', 'details': analysis});
      break;
    }
    // otherwise consider phase clean and continue
  }

  if (issues.isNotEmpty) {
    stdout.writeln('\nFound gaps in prior phases:');
    for (final it in issues) {
      stdout.writeln('- Phase ${it['phase']}: ${it['issue']}');
      if (it.containsKey('details')) stdout.writeln('  details: ${it['details']}');
    }
    if (!force) {
      stdout.writeln('\nOptions:');
      stdout.writeln('  1) Resolve gaps first (stop)');
      stdout.writeln('  2) Defer gaps to backlog and continue (not implemented)');
      stdout.writeln('  3) Force advance: re-run with --force');
      exit(3);
    } else {
      stdout.writeln('Force flag present: advancing despite gaps');
    }
  }

  // determine next unstarted phase: first phase with no directory or with no plan
  int? nextPhase;
  for (final p in phases) {
    final dir = dirs.firstWhere((d) => d.contains(p.toString().padLeft(2, '0')) || d.contains(p.toString()), orElse: () => '');
    if (dir.isEmpty) {
      nextPhase = p;
      break;
    }
    final analysis = analyzePhaseDir(Directory(dir));
    if (analysis['hasPlan'] == false) {
      nextPhase = p;
      break;
    }
    // if plan exists and verified PASS then continue
  }

  if (nextPhase == null) {
    stdout.writeln('No next phase found; all phases appear planned and verified.');
    exit(0);
  }

  stdout.writeln('\nNext logical step: run planning for Phase $nextPhase');
  stdout.writeln('Suggested command: gsd-plan-phase ${nextPhase.toString().padLeft(2, '0')}-<slug>');
  stdout.writeln('(Example: /gsd-plan-phase ${nextPhase.toString()} --verify)');
}
