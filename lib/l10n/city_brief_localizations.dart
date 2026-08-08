import '../domain/models/pre_election_city_brief.dart';
import '../domain/models/city_problem.dart';
import 'app_localizations.dart';

extension LocalizedCityBrief on AppLocalizations {
  bool get _filipinoBrief => localeName.startsWith('fil');

  String additionalCityConditions(int count) => _filipinoBrief
      ? '$count pang kondisyon ng lungsod'
      : '$count more city conditions';

  String get affectedGroupsLabel =>
      _filipinoBrief ? 'Mga grupong apektado' : 'Affected groups';

  String get possibleCausesLabel =>
      _filipinoBrief ? 'Mga posibleng dahilan' : 'Possible causes';

  String get policyPathsLabel =>
      _filipinoBrief ? 'Mga maaaring tugon' : 'Policy paths';

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
    if (item.isFlavor) return _flavorTitle(item.templateVariant);
    final family = item.issueFamily;
    if (family != null) return _issueNewsTitle(family, item.templateVariant);
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
    if (item.isFlavor) return _flavorSummary(cityName);
    final family = item.issueFamily;
    if (family != null) return _issueNewsSummary(family, cityName);
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
    if (voice.sentiment == CitizenSentiment.hopeful ||
        voice.sentiment == CitizenSentiment.positive) {
      return _positiveVoice(voice.issueFamily);
    }
    if (voice.problemId.isNotEmpty) return _issueVoice(voice);
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

  String citizenSentimentLabel(CitizenSentiment sentiment) => _filipinoBrief
      ? switch (sentiment) {
          CitizenSentiment.concerned => 'Nag-aalala',
          CitizenSentiment.frustrated => 'Naiinis',
          CitizenSentiment.hopeful => 'Umaasa',
          CitizenSentiment.positive => 'Positibo',
          CitizenSentiment.watchful => 'Mapagmasid',
        }
      : switch (sentiment) {
          CitizenSentiment.concerned => 'Concerned',
          CitizenSentiment.frustrated => 'Frustrated',
          CitizenSentiment.hopeful => 'Hopeful',
          CitizenSentiment.positive => 'Positive',
          CitizenSentiment.watchful => 'Watchful',
        };

  String _issueNewsTitle(CityIssueFamily family, int variant) {
    final alternate = variant.isOdd;
    if (_filipinoBrief) {
      return switch (family) {
        CityIssueFamily.floodingDrainage =>
          alternate
              ? 'Inilabas ang audit sa drainage'
              : 'Muling binaha ang mabababang kalye',
        CityIssueFamily.corruptionPublicFunds =>
          alternate
              ? 'Sinusuri ang mga kontrata ng lungsod'
              : 'Humihingi ng resibo ang budget watchers',
        CityIssueFamily.unfinishedRoads =>
          alternate
              ? 'Lumampas na naman sa deadline ang roadworks'
              : 'Mga detour, patuloy sa mga barangay',
        CityIssueFamily.drugsCommunitySafety =>
          alternate
              ? 'Nagpulong ang komunidad para sa ligtas na kalye'
              : 'Hindi pantay ang kaligtasan sa gabi',
        CityIssueFamily.garbageCleanliness =>
          alternate
              ? 'Sinuri ang mga rutang hindi nakokolektahan'
              : 'Basura, naiipon malapit sa daluyan ng tubig',
        CityIssueFamily.trafficTransport =>
          alternate
              ? 'Sinukat ang oras ng biyahe sa rush hour'
              : 'Hindi maaasahang ruta, dagdag gastos sa biyahero',
        CityIssueFamily.waterSupply =>
          alternate
              ? 'Lumang tubo, kasama sa repair list'
              : 'Water warning, bumalik sa ilang distrito',
        CityIssueFamily.healthcareCapacity =>
          alternate
              ? 'Kulang pa rin ang kawani sa mga klinika'
              : 'Mahabang pila, hamon sa serbisyong pangkalusugan',
        CityIssueFamily.employmentQuality =>
          alternate
              ? 'Pansamantalang trabaho ang karamihan sa hiring'
              : 'Matatag na trabaho, mabagal ang pagdami',
        CityIssueFamily.costOfLiving =>
          alternate
              ? 'Sinukat muli ang presyo ng pangunahing bilihin'
              : 'Gastos ng pamilya, mas mabilis sa kita',
        CityIssueFamily.governmentServices =>
          alternate
              ? 'Sinukat ang haba ng permit queue'
              : 'Paulit-ulit na papeles, reklamo ng aplikante',
        CityIssueFamily.educationCapacity =>
          alternate
              ? 'Kulang ang silid sa bagong enrollment count'
              : 'Siksikang klase, hamon sa mga guro',
      };
    }
    return switch (family) {
      CityIssueFamily.floodingDrainage =>
        alternate
            ? 'Drainage audit identifies weak points'
            : 'Low-lying streets flood again',
      CityIssueFamily.corruptionPublicFunds =>
        alternate
            ? 'City contracts face closer review'
            : 'Budget watchers ask for receipts',
      CityIssueFamily.unfinishedRoads =>
        alternate
            ? 'Roadworks miss another deadline'
            : 'Detours continue across neighborhoods',
      CityIssueFamily.drugsCommunitySafety =>
        alternate
            ? 'Community meets over safer streets'
            : 'Nighttime safety remains uneven',
      CityIssueFamily.garbageCleanliness =>
        alternate
            ? 'Missed collection routes face review'
            : 'Waste builds up near waterways',
      CityIssueFamily.trafficTransport =>
        alternate
            ? 'Rush-hour travel times measured'
            : 'Unreliable routes cost commuters',
      CityIssueFamily.waterSupply =>
        alternate
            ? 'Aging pipes added to repair list'
            : 'Water warning returns in several districts',
      CityIssueFamily.healthcareCapacity =>
        alternate
            ? 'Clinics continue to report staff gaps'
            : 'Long queues test public health services',
      CityIssueFamily.employmentQuality =>
        alternate
            ? 'Temporary work dominates new hiring'
            : 'Stable job growth remains slow',
      CityIssueFamily.costOfLiving =>
        alternate
            ? 'Essential-goods prices checked again'
            : 'Household costs rise faster than income',
      CityIssueFamily.governmentServices =>
        alternate
            ? 'Permit queue times put under review'
            : 'Applicants report repeated paperwork',
      CityIssueFamily.educationCapacity =>
        alternate
            ? 'Enrollment count reveals room shortage'
            : 'Crowded classes challenge teachers',
    };
  }

  String _issueNewsSummary(CityIssueFamily family, String cityName) {
    final subject = _filipinoBrief
        ? switch (family) {
            CityIssueFamily.floodingDrainage =>
              'drainage at paghahanda sa baha',
            CityIssueFamily.corruptionPublicFunds =>
              'pagbili at paggamit ng pondong publiko',
            CityIssueFamily.unfinishedRoads => 'naantalang proyekto sa kalsada',
            CityIssueFamily.drugsCommunitySafety =>
              'kaligtasan, pag-iwas, at paggamot',
            CityIssueFamily.garbageCleanliness =>
              'koleksiyon ng basura at ilegal na pagtatapon',
            CityIssueFamily.trafficTransport =>
              'ruta, trapiko, at oras ng biyahe',
            CityIssueFamily.waterSupply => 'suplay at kalidad ng tubig',
            CityIssueFamily.healthcareCapacity =>
              'kawani, suplay, at pila sa klinika',
            CityIssueFamily.employmentQuality =>
              'katatagan at kalidad ng trabaho',
            CityIssueFamily.costOfLiving => 'presyo, renta, at kita ng pamilya',
            CityIssueFamily.governmentServices =>
              'proseso, pila, at mga permit',
            CityIssueFamily.educationCapacity =>
              'silid-aralan, guro, at kagamitan',
          }
        : switch (family) {
            CityIssueFamily.floodingDrainage => 'drainage and flood readiness',
            CityIssueFamily.corruptionPublicFunds =>
              'procurement and public spending',
            CityIssueFamily.unfinishedRoads => 'delayed road projects',
            CityIssueFamily.drugsCommunitySafety =>
              'safety, prevention, and treatment',
            CityIssueFamily.garbageCleanliness =>
              'waste collection and illegal dumping',
            CityIssueFamily.trafficTransport =>
              'routes, congestion, and travel times',
            CityIssueFamily.waterSupply => 'water supply and quality',
            CityIssueFamily.healthcareCapacity =>
              'clinic staff, supplies, and queues',
            CityIssueFamily.employmentQuality => 'job stability and quality',
            CityIssueFamily.costOfLiving =>
              'prices, rent, and household income',
            CityIssueFamily.governmentServices =>
              'process steps, queues, and permits',
            CityIssueFamily.educationCapacity =>
              'classrooms, teachers, and materials',
          };
    return _filipinoBrief
        ? 'Pinagsama ng Chronicle ang mga rekord at ulat ng komunidad tungkol sa $subject sa $cityName.'
        : 'The Chronicle combines public records and community reports about $subject in $cityName.';
  }

  String _flavorTitle(int variant) {
    const english = [
      'Weekend market adds an early opening hour',
      'Students repaint a well-used waiting shed',
      'Neighborhood league reaches its final round',
      'Library desk starts a book-swap shelf',
      'Community garden shares its first harvest',
      'Local band rehearses for the plaza program',
    ];
    const filipino = [
      'Mas maagang magbubukas ang weekend market',
      'Pinintahan ng mga estudyante ang waiting shed',
      'Final round na ng liga sa barangay',
      'May bagong book-swap shelf sa aklatan',
      'Ibinahagi ang unang ani ng community garden',
      'Naghahanda ang banda para sa programa sa plaza',
    ];
    return (_filipinoBrief ? filipino : english)[variant % english.length];
  }

  String _flavorSummary(String cityName) => _filipinoBrief
      ? 'Isang maliit ngunit tunay na bahagi ng araw-araw na buhay sa $cityName—walang krisis, campaign claim, o nakatagong epekto sa laro.'
      : 'A small but genuine part of daily life in $cityName—with no crisis, campaign claim, or hidden gameplay effect.';

  String _positiveVoice(CityIssueFamily family) {
    final subject = _filipinoBrief
        ? switch (family) {
            CityIssueFamily.floodingDrainage => 'paglilinis ng kanal',
            CityIssueFamily.corruptionPublicFunds => 'pagbubukas ng mga rekord',
            CityIssueFamily.unfinishedRoads => 'pag-usad ng pagkukumpuni',
            CityIssueFamily.drugsCommunitySafety => 'programa para sa kabataan',
            CityIssueFamily.garbageCleanliness => 'sama-samang paglilinis',
            CityIssueFamily.trafficTransport => 'mas maayos na ruta',
            CityIssueFamily.waterSupply => 'pag-ayos ng linya ng tubig',
            CityIssueFamily.healthcareCapacity => 'dedikasyon ng clinic staff',
            CityIssueFamily.employmentQuality => 'bagong apprenticeship',
            CityIssueFamily.costOfLiving => 'kooperatiba sa komunidad',
            CityIssueFamily.governmentServices => 'mas malinaw na checklist',
            CityIssueFamily.educationCapacity => 'bagong silid-aralan',
          }
        : switch (family) {
            CityIssueFamily.floodingDrainage => 'drain-clearing work',
            CityIssueFamily.corruptionPublicFunds =>
              'opening of public records',
            CityIssueFamily.unfinishedRoads => 'visible repair progress',
            CityIssueFamily.drugsCommunitySafety => 'youth program',
            CityIssueFamily.garbageCleanliness => 'community cleanup',
            CityIssueFamily.trafficTransport => 'more reliable route',
            CityIssueFamily.waterSupply => 'water-line repair',
            CityIssueFamily.healthcareCapacity => 'clinic staff',
            CityIssueFamily.employmentQuality => 'new apprenticeship',
            CityIssueFamily.costOfLiving => 'community cooperative',
            CityIssueFamily.governmentServices => 'clearer service checklist',
            CityIssueFamily.educationCapacity => 'new classroom',
          };
    return _filipinoBrief
        ? 'May nakikita kaming pag-usad sa $subject. Maliit pa, pero puwedeng palakihin kung tuloy-tuloy.'
        : 'We can see progress in the $subject. It is still small, but consistent work could build on it.';
  }

  String _issueVoice(CitizenVoice voice) {
    final alternate =
        voice.sentiment == CitizenSentiment.watchful ||
        voice.templateVariant.isOdd;
    if (_filipinoBrief) {
      return switch (voice.issueFamily) {
        CityIssueFamily.floodingDrainage =>
          alternate
              ? 'Babantayan namin kung lilinisin ang kanal bago ang susunod na malakas na ulan.'
              : 'Paulit-ulit na pumapasok ang baha sa kalye namin at nawawala ang isang araw ng trabaho.',
        CityIssueFamily.corruptionPublicFunds =>
          alternate
              ? 'Gusto naming makita ang kontrata, presyo, at pangalan ng supplier—hindi slogan lang.'
              : 'Bawat pisong nawawala sa malabong kontrata ay kulang sa tunay na serbisyo.',
        CityIssueFamily.unfinishedRoads =>
          alternate
              ? 'May deadline sa karatula; gusto naming makita kung tugma iyon sa aktuwal na trabaho.'
              : 'Ilang buwan nang barikado ang harap ng tindahan pero kakaunti ang gumagawa.',
        CityIssueFamily.drugsCommunitySafety =>
          alternate
              ? 'Kailangan ang ligtas na kalye kasama ang prevention at treatment, hindi takot lang.'
              : 'Hindi kampante ang mga umuuwi sa gabi, lalo na ang mga kabataan at night-shift worker.',
        CityIssueFamily.garbageCleanliness =>
          alternate
              ? 'Handa kaming tumulong maglinis, pero kailangan ding dumating ang regular na koleksiyon.'
              : 'Kapag hindi dumarating ang truck, napupunta ang basura sa tabi ng kanal.',
        CityIssueFamily.trafficTransport =>
          alternate
              ? 'Susukatin namin kung talagang bumilis at naging mas maaasahan ang bagong ruta.'
              : 'Oras sa pamilya ang nauubos kapag hindi dumarating sa oras ang sasakyan.',
        CityIssueFamily.waterSupply =>
          alternate
              ? 'Gusto namin ng regular na test result, hindi assurance lang pagkatapos ng warning.'
              : 'Kapag bumababa ang pressure, hindi namin alam kung ligtas pa ang tubig sa gripo.',
        CityIssueFamily.healthcareCapacity =>
          alternate
              ? 'Masipag ang clinic staff, pero kailangan nila ng dagdag na tao, gamot, at oras.'
              : 'Hindi dapat maubos ang buong araw ng trabaho para lang sa isang checkup.',
        CityIssueFamily.employmentQuality =>
          alternate
              ? 'May saysay ang training kung may matatag at disenteng trabaho sa dulo.'
              : 'May hiring nga, pero marami ang kontratang nawawala pagkatapos ng ilang buwan.',
        CityIssueFamily.costOfLiving =>
          alternate
              ? 'Linggo-linggo kong kinukumpara ang presyo dahil hindi sumasabay ang kita.'
              : 'Sabay-sabay tumaas ang pagkain, renta, kuryente, at pamasahe.',
        CityIssueFamily.governmentServices =>
          alternate
              ? 'Isang malinaw na checklist at totoong queue time ang malaking tulong na agad.'
              : 'Paulit-ulit kaming bumabalik dahil may bagong requirement sa bawat counter.',
        CityIssueFamily.educationCapacity =>
          alternate
              ? 'Ginagawa ng mga guro ang makakaya nila, pero hindi puwedeng siksikan habang-buhay.'
              : 'Hati ang oras at gamit ng mga estudyante dahil kulang ang silid-aralan.',
      };
    }
    return switch (voice.issueFamily) {
      CityIssueFamily.floodingDrainage =>
        alternate
            ? 'We will watch whether the drains are cleared before the next heavy rain.'
            : 'The same street floods again, and families lose another day of work.',
      CityIssueFamily.corruptionPublicFunds =>
        alternate
            ? 'Show us the contract, price, and supplier—not another slogan.'
            : 'Every peso lost through an unclear contract is missing from a real service.',
      CityIssueFamily.unfinishedRoads =>
        alternate
            ? 'The sign lists a deadline; we want to see whether the work matches it.'
            : 'Barricades have blocked the shops for months, but little work is visible.',
      CityIssueFamily.drugsCommunitySafety =>
        alternate
            ? 'Safe streets need prevention and treatment too, not fear alone.'
            : 'People coming home at night do not feel safe, especially young and shift workers.',
      CityIssueFamily.garbageCleanliness =>
        alternate
            ? 'We will help clean, but regular collection still has to arrive.'
            : 'When the truck misses us, rubbish ends up beside the drainage canal.',
      CityIssueFamily.trafficTransport =>
        alternate
            ? 'We will measure whether the new route is actually faster and more reliable.'
            : 'Unreliable transport takes away hours that should be spent with family.',
      CityIssueFamily.waterSupply =>
        alternate
            ? 'We need regular test results, not reassurance only after a warning.'
            : 'When pressure drops, we do not know whether the tap is still safe.',
      CityIssueFamily.healthcareCapacity =>
        alternate
            ? 'Clinic staff work hard, but they need more people, medicine, and hours.'
            : 'A basic checkup should not consume an entire workday.',
      CityIssueFamily.employmentQuality =>
        alternate
            ? 'Training matters when a stable, decent job exists at the end.'
            : 'There is hiring, but too many contracts disappear after a few months.',
      CityIssueFamily.costOfLiving =>
        alternate
            ? 'I compare prices every week because our income is not keeping up.'
            : 'Food, rent, power, and transport all rose at the same time.',
      CityIssueFamily.governmentServices =>
        alternate
            ? 'A clear checklist and honest queue time would help immediately.'
            : 'We keep returning because every counter asks for something new.',
      CityIssueFamily.educationCapacity =>
        alternate
            ? 'Teachers do what they can, but overcrowding cannot become permanent.'
            : 'Students split time and materials because there are not enough rooms.',
    };
  }

  String _conditionLabel(int value) => switch (value) {
    <= 19 => stateCritical,
    <= 39 => statePoor,
    <= 59 => stateUnstable,
    <= 79 => stateFunctional,
    _ => stateStrong,
  };
}
