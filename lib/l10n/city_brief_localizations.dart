import '../domain/models/pre_election_city_brief.dart';
import 'app_localizations.dart';

extension LocalizedCityBrief on AppLocalizations {
  bool get _filipinoBrief => localeName.startsWith('fil');

  String cityMetricLabel(CityMetricKind kind) => _filipinoBrief
      ? switch (kind) {
          CityMetricKind.reliableFoodAccess => 'May maaasahang pagkain',
          CityMetricKind.financiallySecureHouseholds =>
            'Pamilyang may matatag na badyet',
          CityMetricKind.clinicWaitTime => 'Karaniwang hintay sa klinika',
          CityMetricKind.classroomSize => 'Karaniwang laki ng klase',
          CityMetricKind.reliableWater => 'May maaasahang tubig',
          CityMetricKind.stableEmployment => 'May matatag na trabaho',
          CityMetricKind.commuteTime => 'Karaniwang biyahe',
          CityMetricKind.floodReadiness => 'Handa sa baha',
          CityMetricKind.publicTrust => 'Tiwala ng publiko',
          CityMetricKind.budgetRoom => 'Luwag sa badyet',
        }
      : switch (kind) {
          CityMetricKind.reliableFoodAccess => 'Reliable food access',
          CityMetricKind.financiallySecureHouseholds =>
            'Financially secure households',
          CityMetricKind.clinicWaitTime => 'Average clinic wait',
          CityMetricKind.classroomSize => 'Average class size',
          CityMetricKind.reliableWater => 'Reliable water service',
          CityMetricKind.stableEmployment => 'Stable employment',
          CityMetricKind.commuteTime => 'Average commute',
          CityMetricKind.floodReadiness => 'Flood readiness',
          CityMetricKind.publicTrust => 'Public trust',
          CityMetricKind.budgetRoom => 'Budget room',
        };

  String cityMetricValue(CityBriefMetric metric) => switch (metric.unit) {
    CityMetricUnit.percent => '${metric.value.round()}%',
    CityMetricUnit.hours =>
      _filipinoBrief
          ? '${metric.value.toStringAsFixed(1)} oras'
          : '${metric.value.toStringAsFixed(1)} hrs',
    CityMetricUnit.people =>
      _filipinoBrief
          ? '${metric.value.round()} / silid'
          : '${metric.value.round()} / room',
    CityMetricUnit.minutes =>
      _filipinoBrief
          ? '${metric.value.round()} minuto'
          : '${metric.value.round()} min',
    CityMetricUnit.condition => _conditionLabel(metric.conditionScore),
  };

  String citySeverityLabel(int value) => _filipinoBrief
      ? switch (value) {
          >= 80 => 'Kritikal',
          >= 65 => 'Mataas',
          >= 45 => 'Katamtaman',
          _ => 'Mababa',
        }
      : switch (value) {
          >= 80 => 'Critical',
          >= 65 => 'High',
          >= 45 => 'Moderate',
          _ => 'Low',
        };

  String cityUrgencyLabel(int value) => _filipinoBrief
      ? switch (value) {
          >= 85 => 'Agad-agad',
          >= 70 => 'Mataas',
          >= 50 => 'Malapit na',
          _ => 'Bantayan',
        }
      : switch (value) {
          >= 85 => 'Immediate',
          >= 70 => 'High',
          >= 50 => 'Near-term',
          _ => 'Monitor',
        };

  String cityTopicLabel(CityBriefTopic topic) => _filipinoBrief
      ? switch (topic) {
          CityBriefTopic.food => 'Pagkain',
          CityBriefTopic.poverty => 'Gastos ng pamumuhay',
          CityBriefTopic.health => 'Kalusugan',
          CityBriefTopic.education => 'Edukasyon',
          CityBriefTopic.water => 'Tubig',
          CityBriefTopic.jobs => 'Trabaho',
          CityBriefTopic.cityServices => 'Serbisyo ng lungsod',
          CityBriefTopic.climate => 'Klima at baha',
        }
      : switch (topic) {
          CityBriefTopic.food => 'Food',
          CityBriefTopic.poverty => 'Cost of living',
          CityBriefTopic.health => 'Health',
          CityBriefTopic.education => 'Education',
          CityBriefTopic.water => 'Water',
          CityBriefTopic.jobs => 'Jobs',
          CityBriefTopic.cityServices => 'City services',
          CityBriefTopic.climate => 'Climate and flooding',
        };

  String cityNewsSourceLabel(CityNewsSource source) => _filipinoBrief
      ? switch (source) {
          CityNewsSource.cityDesk => 'Tanggapan ng Balita ng Lungsod',
          CityNewsSource.recordsOffice => 'Tanggapan ng mga Rekord',
          CityNewsSource.publicMedia => 'Pampublikong Media',
          CityNewsSource.communityFeed => 'Balita ng Komunidad',
        }
      : switch (source) {
          CityNewsSource.cityDesk => 'City News Desk',
          CityNewsSource.recordsOffice => 'City Records Office',
          CityNewsSource.publicMedia => 'Bayhaven Public Media',
          CityNewsSource.communityFeed => 'Community Feed',
        };

  String cityNewsTitle(CityNewsItem item, String cityName) {
    if (item.isUnverified) {
      return _filipinoBrief
          ? 'Kumakalat na pahayag tungkol sa ${cityTopicLabel(item.topic).toLowerCase()}'
          : 'A claim about ${cityTopicLabel(item.topic).toLowerCase()} is spreading';
    }
    final second = item.templateVariant.isOdd;
    if (_filipinoBrief) {
      return switch (item.topic) {
        CityBriefTopic.food =>
          second
              ? 'Lumalawak ang agwat sa access sa abot-kayang pagkain'
              : 'Mabigat sa badyet ng pamilya ang presyo sa pamilihan',
        CityBriefTopic.poverty =>
          second
              ? 'Mas maraming pamilya ang nahuhuli sa bayarin'
              : 'Renta at pangunahing gastos, patuloy ang pagtaas',
        CityBriefTopic.health =>
          second
              ? 'Kulang sa kawani ang mga neighborhood clinic'
              : 'Mahaba pa rin ang pila sa pampublikong klinika',
        CityBriefTopic.education =>
          second
              ? 'Hindi pantay ang kagamitan sa mga paaralan ng $cityName'
              : 'Siksikang klase ang humahamon sa mga guro',
        CityBriefTopic.water =>
          second
              ? 'Lumang linya ng tubig, sentro ng usapin sa halalan'
              : 'Bumabalik ang water warning matapos ang malakas na ulan',
        CityBriefTopic.jobs =>
          second
              ? 'Pana-panahong trabaho ang nangingibabaw sa bagong hiring'
              : 'Mabagal ang pagbangon ng matatag na trabaho',
        CityBriefTopic.cityServices =>
          second
              ? 'Naantalang pagkukumpuni, ramdam sa mga barangay'
              : 'Mahabang biyahe ang nagpapahirap sa mga manggagawa',
        CityBriefTopic.climate =>
          second
              ? 'Hinahanap ng mga residente ang pangmatagalang flood plan'
              : 'Hindi makahabol ang drainage sa mas malakas na ulan',
      };
    }
    return switch (item.topic) {
      CityBriefTopic.food =>
        second
            ? 'Affordable food gaps widen across neighborhoods'
            : 'Market prices strain family budgets',
      CityBriefTopic.poverty =>
        second
            ? 'More households fall behind on basic bills'
            : 'Rent and essential costs continue to climb',
      CityBriefTopic.health =>
        second
            ? 'Neighborhood clinics report staffing gaps'
            : 'Public clinic queues remain long',
      CityBriefTopic.education =>
        second
            ? 'School resources remain uneven across $cityName'
            : 'Crowded classrooms challenge teachers',
      CityBriefTopic.water =>
        second
            ? 'Aging water lines become an election issue'
            : 'Water warnings return after heavy rain',
      CityBriefTopic.jobs =>
        second
            ? 'Seasonal work dominates new hiring'
            : 'Stable employment recovery remains slow',
      CityBriefTopic.cityServices =>
        second
            ? 'Delayed repairs are felt across neighborhoods'
            : 'Long commutes weigh on workers',
      CityBriefTopic.climate =>
        second
            ? 'Residents seek a long-term flood plan'
            : 'Drainage falls behind heavier rainfall',
    };
  }

  String cityNewsSummary(CityNewsItem item, String cityName) {
    if (item.isUnverified) {
      return _filipinoBrief
          ? 'Walang dokumento o pinangalanang source ang post. Inilalarawan nito ang kasalukuyang pag-aalala, ngunit hindi ito beripikadong rekord.'
          : 'The post supplies no document or named source. It reflects current concern, but it is not a verified record.';
    }
    if (_filipinoBrief) {
      return switch (item.topic) {
        CityBriefTopic.food =>
          'Ipinapakita ng price checks ang hindi pantay na access sa abot-kayang pagkain sa mga distrito ng $cityName.',
        CityBriefTopic.poverty =>
          'Mas mabilis ang pagtaas ng pangunahing gastos kaysa kita ng maraming sambahayan.',
        CityBriefTopic.health =>
          'Pinagsasaluhan ng mga klinika ang limitadong kawani, suplay, at oras ng serbisyo.',
        CityBriefTopic.education =>
          'Nagkakaiba ang laki ng klase at access sa learning materials sa bawat distrito.',
        CityBriefTopic.water =>
          'Ipinapakita ng maintenance records na malaki ang pangangailangan sa lumang water network.',
        CityBriefTopic.jobs =>
          'Dumarami ang panandalian at seasonal na posisyon habang mabagal ang permanenteng hiring.',
        CityBriefTopic.cityServices =>
          'Ang housing strain, transport delays, at repair backlog ay sabay-sabay na nararamdaman.',
        CityBriefTopic.climate =>
          'Inilalantad ng mas malakas na ulan ang kakulangan sa drainage at emergency readiness.',
      };
    }
    return switch (item.topic) {
      CityBriefTopic.food =>
        'Price checks show uneven access to affordable food across $cityName districts.',
      CityBriefTopic.poverty =>
        'Essential costs are rising faster than income for many households.',
      CityBriefTopic.health =>
        'Clinics are sharing limited staff, supplies, and service hours.',
      CityBriefTopic.education =>
        'Class sizes and access to learning materials differ sharply by district.',
      CityBriefTopic.water =>
        'Maintenance records show substantial needs across the aging water network.',
      CityBriefTopic.jobs =>
        'Short-term and seasonal positions are growing while permanent hiring remains slow.',
      CityBriefTopic.cityServices =>
        'Housing strain, transport delays, and the repair backlog are being felt together.',
      CityBriefTopic.climate =>
        'Heavier rain is exposing gaps in drainage and emergency readiness.',
    };
  }

  String citizenDistrictLabel(CitizenDistrict district) => switch (district) {
    CitizenDistrict.northWard => 'North Ward',
    CitizenDistrict.riverside => 'Riverside',
    CitizenDistrict.oldMarket => 'Old Market',
    CitizenDistrict.southPoint => 'South Point',
    CitizenDistrict.harborDistrict => 'Harbor District',
    CitizenDistrict.hillview => 'Hillview',
  };

  String citizenRoleLabel(CitizenRole role) => _filipinoBrief
      ? switch (role) {
          CitizenRole.vendor => 'Tindera sa palengke',
          CitizenRole.caregiver => 'Tagapag-alaga',
          CitizenRole.clinicWorker => 'Kawani ng klinika',
          CitizenRole.student => 'Estudyante',
          CitizenRole.teacher => 'Guro',
          CitizenRole.commuter => 'Biyahero',
          CitizenRole.tradesWorker => 'Manggagawang bihasa',
          CitizenRole.resident => 'Residente',
        }
      : switch (role) {
          CitizenRole.vendor => 'Market vendor',
          CitizenRole.caregiver => 'Caregiver',
          CitizenRole.clinicWorker => 'Clinic worker',
          CitizenRole.student => 'Student',
          CitizenRole.teacher => 'Teacher',
          CitizenRole.commuter => 'Commuter',
          CitizenRole.tradesWorker => 'Trades worker',
          CitizenRole.resident => 'Resident',
        };

  String citizenVoiceQuote(CitizenVoice voice) {
    final variant = voice.templateVariant % 3;
    final english = switch (voice.topic) {
      CityBriefTopic.food => [
        'I compare prices twice before I fill one basket now.',
        'A full day at the market does not stretch as far as it used to.',
        'Families are choosing which meals they can afford.',
      ],
      CityBriefTopic.poverty => [
        'One surprise bill can put a household behind for months.',
        'Rent, transport, and food all rose at the same time.',
        'People are working, but many still cannot build any cushion.',
      ],
      CityBriefTopic.health => [
        'The staff keep moving, but the queue keeps growing.',
        'A checkup should not require losing an entire workday.',
        'We need supplies and people, not another temporary promise.',
      ],
      CityBriefTopic.education => [
        'Teachers are doing more with rooms that are already full.',
        'Some students share materials that others can take home.',
        'The school needs repairs before the next heavy rain.',
      ],
      CityBriefTopic.water => [
        'After hard rain, we wait before trusting the tap.',
        'We need repairs that last beyond one election season.',
        'Clean water should not depend on which street you live on.',
      ],
      CityBriefTopic.jobs => [
        'There is work, but too much of it disappears after a few months.',
        'Training helps only when there is a stable job at the end.',
        'People want work that can support a household, not just a headline.',
      ],
      CityBriefTopic.cityServices => [
        'The commute takes time I should be spending with my family.',
        'We report the same broken road and wait for another season.',
        'Small delays across the city become a very long day.',
      ],
      CityBriefTopic.climate => [
        'Every rainy season shows us the same weak points.',
        'Emergency crews help, but preparation has to start earlier.',
        'We need drainage plans that survive more than one storm.',
      ],
    };
    final filipino = switch (voice.topic) {
      CityBriefTopic.food => [
        'Dalawang beses ko nang ikinukumpara ang presyo bago punuin ang isang basket.',
        'Hindi na kasya tulad ng dati ang kita sa isang araw sa palengke.',
        'Pinipili na ng mga pamilya kung aling pagkain ang kayang bilhin.',
      ],
      CityBriefTopic.poverty => [
        'Isang biglaang bayarin lang, ilang buwan nang hahabol ang pamilya.',
        'Sabay-sabay tumaas ang renta, pamasahe, at pagkain.',
        'Nagtatrabaho ang mga tao pero marami pa ring walang naiipon.',
      ],
      CityBriefTopic.health => [
        'Tuloy-tuloy ang kawani pero humahaba pa rin ang pila.',
        'Hindi dapat ubos ang isang araw ng trabaho para sa checkup.',
        'Kailangan namin ng suplay at tao, hindi panandaliang pangako.',
      ],
      CityBriefTopic.education => [
        'Mas maraming ginagawa ang guro sa silid na puno na.',
        'May estudyanteng naghahati sa gamit na naiuuwi ng iba.',
        'Kailangang ayusin ang paaralan bago ang susunod na malakas na ulan.',
      ],
      CityBriefTopic.water => [
        'Kapag malakas ang ulan, naghihintay muna kami bago pagkatiwalaan ang gripo.',
        'Kailangan namin ng ayos na tatagal lampas sa isang halalan.',
        'Hindi dapat nakadepende sa kalye ang malinis na tubig.',
      ],
      CityBriefTopic.jobs => [
        'May trabaho, pero marami ang nawawala makalipas lang ang ilang buwan.',
        'May saysay ang training kung may matatag na trabaho sa dulo.',
        'Trabahong kayang bumuhay ng pamilya ang kailangan, hindi headline lang.',
      ],
      CityBriefTopic.cityServices => [
        'Nauubos sa biyahe ang oras na dapat kasama ko ang pamilya.',
        'Paulit-ulit naming nirereport ang sirang daan at naghihintay ulit.',
        'Ang maliliit na delay ay nagiging napakahabang araw.',
      ],
      CityBriefTopic.climate => [
        'Bawat tag-ulan, pareho ang mahinang bahagi ng lungsod.',
        'Tumutulong ang emergency crew pero dapat mas maaga ang paghahanda.',
        'Kailangan ng drainage plan na tatagal sa higit sa isang bagyo.',
      ],
    };
    return (_filipinoBrief ? filipino : english)[variant];
  }

  String _conditionLabel(int value) => switch (value) {
    <= 19 => stateCritical,
    <= 39 => statePoor,
    <= 59 => stateUnstable,
    <= 79 => stateFunctional,
    _ => stateStrong,
  };
}
