# Resibo, Please - Current System Report

> October 2026 documentation audit: repository source was reviewed without
> running the app or verification commands. Current facts are five generated
> candidates, save schema 10, candidate generation version 1, and Living City
> generation version 4. See `../RESIBO_PROJECT_CONTEXT_HANDOFF.md` for the
> source-led cross-system handoff.

> October 2026 update: the post-election MVP now continues across elections and
> preserves administration history, predictions, accountability receipts, and
> bounded citizen-action outcomes. The deterministic 365-day Living City still
> drives event timing, chains, projects, Chronicle, News, TV, CityBook, schema-10
> persistence, and the final report. See
> [CITY_SIMULATION_ARCHITECTURE.md](CITY_SIMULATION_ARCHITECTURE.md).
>
> The persistent-city update also adds Political History, Resibo ng Bayan,
> optional prediction receipts, two bounded citizen actions, and a derived
> Civic Profile with four practice tracks and neutral accomplishments. Later
> administrations apply cross-term event-template pressure to reduce repetition
> while still allowing severe unresolved issues to recur. Later elections can
> also gain one pressure-supported authored concern or retire one substantially
> improved concern while keeping four to six active issues.

## 1. Current System Overview

**Resibo, Please** is a fictional civic decision simulation game. The player
acts as a voter in a fictional configured city, reviews the condition of the
city, investigates five generated mayoral candidates, casts a vote, and observes the effects of
the elected candidate's term.

The current version supports repeated local election/administration loops. The
multi-election foundation is implemented and automated-tested, while its
dedicated political-history UI and richer career memory remain in progress:

1. Create and configure a city save.
2. Review the city's problems and starting condition.
3. Investigate the candidates, campaign material, debate statements, and
   evidence files.
4. Collect important findings on a personal Receipts Board.
5. Vote for one candidate.
6. Reveal the winning candidate.
7. Observe or fast-forward a deterministic 365-day living term.
8. Read the final term report.

All candidates, political parties, media outlets, records, and events are
fictional. The game does not evaluate real politicians or provide official
election advice.

## 2. Main Feature: Checking and Investigating Candidates

Candidate investigation is the main educational feature of the current game.
It is designed to move the player from a quick first impression toward deeper
evidence checking without turning the experience into one enormous text page.

Normal city creation now contains five independently rolled, deliberately
imperfect candidates. Maya Vargas, Julian Pratt, and Victor Chen remain in the
repository as the authored reference/debug scenario, not the normal generated
ballot.

The game never displays a best-candidate label, match percentage, overall
grade, hidden quality band, or voting recommendation. Players are expected to
form their own judgment from public information and the needs of their city.

Research progression now has one optional organization benefit. At Research
Level 2, the dossier's **Source Desk** can group visible files by bookmark and
review state, then by source type. It does not unlock a file, change its cost,
show hidden truth, or rank candidates.

### 2.0 Procedural election foundation (implemented August 2026)

Pressing **Create City** first generates the configured city's four to six
problems and then creates one mayor-only election containing exactly five
candidates. The roster selects five unique identities from seven reusable
portrait records. Every portrait stores a stable ID, asset path, male/female
name-pool tag, age group, and visual-archetype hint. The same portrait may have
a different fictional identity in another world, but it cannot appear twice in
one election.

The world seed and the current candidate generation version are passed through a stable derived
sub-seed function. Independent paths exist for portrait selection and each
candidate's identity, truth, history, platform, Biography, Campaign Trail,
CityBook, debate, news, and evidence. This prevents an extra random draw in one
presentation system from shifting another candidate's name, the city problems,
or the term simulation.

Each candidate is built in this order:

```text
portrait + compatible fictional name
        -> hidden CandidateTruthProfile
        -> five structured history events
        -> promises + evidence graph
        -> quick summary + Civic Archive Biography
        -> Campaign Trail + CityBook + Debate + News
```

The hidden truth includes competence and implementation tradeoffs, integrity,
corruption risk, coalition skill, communication, budget discipline, crisis
response, adaptability, experience, populism, ambition, policy strengths,
personality tags, information footprint, career origin, controversies with
non-binary truth statuses, and political/social relationships. Career origin
can be political, administrative, professional, business, celebrity/media,
community, advocacy, or public safety. It controls plausible record categories
and public footprint, not candidate morality or quality. The quality band and
raw values are simulation-only. They are never shown as a voter score.

The generated presentation volume per candidate is currently:

- one quick candidate profile and one variable Civic Archive biography;
- five structured life events with evidence citations;
- four promises linked to active city issue families and prior history;
- one neutral Then-vs-Now comparison and two unresolved questions;
- five or six Campaign Trail items;
- four to seven CityBook posts, each with ten contextual comments;
- participation in three shared issue-rooted debate topics;
- one underlying candidate-record news event with three outlet framings; and
- nine meaningful evidence files with support/context/correction/unlock links.

Candidate field experience affects generated experience. Campaign noise affects
the amount of public Campaign Trail/CityBook material, but does not reroll
identity or hidden truth. City problems bias backgrounds and promises without
forcing every candidate to be a perfect match.

Career origins are weighted and de-duplicated procedurally. An election may
have no celebrity/outsider, commonly has one broader-background candidate, and
can occasionally have more; no ballot index is reserved for an actor or other
outsider. Non-officeholders receive professional, company, media, service, or
civic-organization records instead of fabricated government procurement files.

The complete generated election is serialized in the current local save schema 7 (introduced in schema 6). It
includes candidate objects, portrait assignments, truth profiles, histories,
promises, Biography data, CityBook profiles/posts/comments, debate messages,
news events/coverage, evidence, and their relationships. Restore reads this
snapshot instead of running the generator again. Schema-5 saves migrate safely
with no procedural snapshot and continue through the authored fallback.

### 2.1 Where candidate checking appears in the game

Candidate checking occurs during the pre-election portion of a city run. After
the player creates a city and reaches the City Brief, the persistent bottom
navigation bar provides three destinations:

- **City** - the city's current problems and indicators;
- **Dossiers** - the candidate roster and investigation area; and
- **Chronicle** - local news and resident voices.

Selecting **Dossiers** opens the Candidate Roster. From there, the player can
open one candidate's Candidate Hub, move between Bio, Promises, Debate, and Records,
open individual evidence readers, save findings to the Receipts Board, return
to the roster, or proceed to Election Day.

The implemented candidate-checking flow is:

```text
City Brief / Chronicle
        |
        v
Candidate Roster
        |
        v
Candidate Hub
  |          |          |         |
 Bio      Promises    Debate    Records
  |          |          |         |
  +----------+----------+---------+---- Evidence Reader
             |
        Campaign Trail
  |
  +---- Receipts Board ---- Candidate Comparison
        |
        v
Election Day
```

The Candidate Hub itself does not show the bottom navigation bar. This keeps
the player focused on the selected candidate. Its upper-left back control
returns to the Candidate Roster, while the receipt icon in the upper-right
opens the Receipts Board.

### 2.2 Overall visual direction of the investigation area

The investigation screens use the same political-cartoon and chunky mobile-game
direction as the main menu, but the information is presented like a collection
of physical case files.

Common visual elements include:

- a dark navy background with a subdued city illustration behind the content;
- cream and parchment panels that resemble paper records;
- thick dark-navy outlines and strong lower shadows;
- stamped labels, folder icons, receipt icons, pins, and record symbols;
- large display headings using the playful game font family;
- smaller readable body text for longer evidence descriptions;
- muted red, teal, gold, and candidate-specific accent colors; and
- tactile buttons with borders, bevel-like layering, and clear pressed areas.

The visual hierarchy intentionally separates public presentation from evidence:
campaign material is colorful and attention-grabbing, while records and source
checks use calmer parchment panels. Candidate colors identify ownership but do
not represent good or bad candidates.

All candidate-facing pages are scrollable, respect safe areas, and use centered
maximum-width content so they do not become excessively wide on desktop. On a
phone, cards become one column. Candidate cards may use two columns on a medium
screen and three on a wide screen. Pulse and Receipt cards use two columns only
when enough horizontal space exists.

### 2.3 Candidate Roster: first comparison screen

The Candidate Roster is the first page under the **Dossiers** navigation item.
It is a full pre-election screen placed between the city-information pages and
the individual Candidate Hubs.

#### Top area

The upper screen header contains:

- the Candidate Files title;
- the active fictional city name;
- a back control leading to the City Brief; and
- an Election Day icon on the right for players ready to vote.

Below it is a parchment introduction panel. Its left side explains the purpose
of reviewing the candidates. Its right side contains global investigation
counters:

- total evidence files opened out of 45 in a normal generated election; and
- remaining investigation points, or an infinity symbol in Relaxed mode.

On narrow screens, these counters move below the introductory text instead of
compressing it.

#### Urgent city case files

The next section is **Urgent Case Files**. It repeats the active city's three
main problems before showing candidates. Each compact cream card contains:

- a problem icon;
- the problem title;
- its current trend; and
- a severity-related accent color.

In the default Bayhaven scenario, the problems are post-flood water
contamination, rising unemployment, and overcrowded public clinics. This
placement reminds players to compare candidates against actual city conditions
instead of comparing personalities in isolation.

#### Candidate-card grid

The candidate cards appear after the urgent case files. They are arranged as:

- one column on narrow phones;
- two columns on medium layouts; and
- three columns on wide browser layouts.

Each card looks like a thick case-file cover. Its upper half is a large
candidate portrait on a candidate-colored gradient. A **Dossier** stamp is
placed at the upper-left, while an opened-file counter such as **0 / 9** appears
near the lower-right of the portrait.

The parchment lower half contains, from top to bottom:

1. candidate name in large uppercase display text;
2. political party in the candidate's accent color;
3. a qualitative experience stamp;
4. the campaign slogan in italic text;
5. one visible documented strength;
6. one visible concern or question; and
7. a candidate-colored **Open Dossier** button.

The qualitative experience label may change with the configured Candidate
Field and city seed. It remains a broad public description such as emerging,
practiced, or established. It is not a recommendation.

After all candidate cards, a centered red **Proceed to Election** button leads
to the ballot. The City/Dossiers/Chronicle navigation remains at the bottom of
this roster screen.

### 2.4 Authored fixture example: Maya Vargas

Maya's roster card currently shows:

- **Name:** Maya Vargas;
- **Party:** Kalinga Civic Alliance;
- **Slogan:** "Care that reaches every street.";
- **Visible strength:** deep public-health experience;
- **Visible concern:** her funding plan relies on optimistic revenue;
- **Portrait accent:** muted purple/magenta; and
- **Progress:** opened Maya files out of her nine available evidence files.

The card gives Maya immediate appeal through health experience but also places
a budget concern directly on the first comparison screen. The player is not
shown her internal implementation, integrity, or corruption-risk values.

### 2.5 Candidate Hub: the central investigation page

Selecting a roster card opens that candidate's Hub. The Hub is the middle and
most important part of candidate checking.

#### Fixed screen header

At the top of the screen is a compact game header containing:

- **Campaign Hub** as the page title;
- the active city name as a subtitle;
- a back button to the Candidate Roster; and
- a Receipts Board icon on the right.

When the player has saved receipts, a small gold count badge appears on the
receipt icon.

#### Candidate identity panel

The first large panel uses a parchment-file appearance. The portrait sits on
the left and the candidate information sits on the right. On a narrow phone,
the portrait becomes smaller so the identity text still fits. The portrait
keeps a stable aspect ratio and never crops the face.

The information side contains:

- large uppercase candidate name;
- party name in the candidate color;
- a pin icon used to prioritize candidates for comparison;
- public identity or career description;
- the office being contested;
- campaign slogan;
- opened dossier count, such as **3 / 9 dossier**;
- remaining investigation points; and
- rhetorical style, such as Charismatic, Aggressive, or Technical.

Rhetorical style only explains how the candidate communicates. It does not say
whether the candidate is honest or correct.

#### Unresolved-question strip

The bottom of the identity panel is a darker parchment strip titled
**Unresolved Questions**. Each question has a question-mark icon and its own pin
button. Pinning a question sends it to the Receipts Board for later review.

#### Main Hub tabs

Four equal-width chunky tabs appear directly below the identity panel:

- **Bio** with an archive/book icon;
- **Promises** with a campaign icon;
- **Debate** with a conversation icon; and
- **Records** with a folder icon.

The selected tab uses muted red. Inactive tabs use dark blue. All use cream
uppercase text, dark outlines, and lower shadows. Bio is selected when the Hub
first opens.

#### Bio and the Civic Archive

Bio is a formal in-world **Bayhaven Civic Archive** article rather than a short
campaign paragraph. It combines a candidate portrait and infobox with birth
year, age, occupation, education, party, current role, hometown, and previous
positions. A compact timeline records education, employment, appointments,
projects, accomplishments, failures, controversies, and other relevant public
events. Article sections vary by candidate instead of forcing every person into
an identical template.

Statements and timeline entries contain numbered, openable citations. They use
the same Evidence Reader, investigation cost, free-follow-up, bookmark, and save
rules as every other dossier entry. Links from Promises can return to and
highlight an exact history entry. The content model also stores an internal
information-footprint value used to vary generated public material; it is
generation metadata and never appears as a quality score.

#### Promises and linked history

Normal generated candidates receive four structured commitments. The preserved
authored fixture contains three commitments per candidate. Each
card presents the candidate's exact campaign wording, a neutral description of
the proposed delivery approach, implementation scope, evidence receipts, and a
link to relevant past history. Promises are attached to broad city-issue
families, so a water, employment, or healthcare commitment can display the
matching active procedural problem without depending on one hard-coded problem
ID.

Where an older statement and current statement differ, a reusable **Then vs
Now** card shows both dates and statements. Context remains collapsed until the
player requests it, and the interface explicitly says that a changed statement
is not an automatic verdict. The player must inspect the receipts and decide.

### 2.6 Campaign Trail: fast campaign feed

The former Pulse is preserved as the expandable **Campaign Trail** at the end
of Promises. It is the quick-reading layer and resembles a campaign/news feed
rather than a database. Generated candidates have five cards, with a sixth
historical/correction card when their information footprint and campaign-noise
setting call for it. The sequence covers introduction, humanizing account,
major promise, complication, defense, and optional resurfaced history.

On a phone, cards form one vertical column. On wide screens, they form two
columns within the centered Hub content.

#### Pulse card layout

Each card contains:

1. a candidate-colored category bar with a content-type icon;
2. a pin icon for saving the entire claim to the Receipts Board;
3. a stable media area or polished placeholder;
4. a large headline;
5. a two- or three-sentence summary;
6. small chips for source, fictional campaign date, and public attention;
7. an **Inspect** button; and
8. an expandable detail area.

Final campaign illustrations have not yet been generated. Media positions are
already reserved with fixed aspect ratios, captions, icons, candidate colors,
and fallback graphics. This prevents layout movement and makes the page look
intentional even while final art is missing.

Pressing **Inspect** expands the card without leaving Pulse. The expanded area
may contain:

- the fuller context;
- important figures;
- the candidate's response;
- missing context;
- a prompt explaining what should be checked next; and
- one or more evidence chips.

The evidence chips form the **Deep Dive** level. Each chip identifies the file
type and whether opening it is free or costs investigation points. Selecting a
chip opens the complete Evidence Reader.

### 2.7 Full Pulse example: Maya Vargas

Maya's Candidate Hub identifies her as a **former health administrator turned
reform candidate** with a **Charismatic** rhetorical style. Her two unresolved
questions are:

1. Where will the clinic expansion budget come from?
2. Could medical suppliers influence future contracts?

Her six Pulse cards currently appear in this order:

| Order | Type | Headline | What the quick summary communicates | Deeper records |
|---|---|---|---|---|
| 1 | Public event | **Vargas opens with a packed clinic rally** | Her neighborhood-care message draws the loudest launch crowd. Inspect reveals two pilot districts and two mobile units. | Campaign advertisement and performance record |
| 2 | Resident reaction | **A nurse remembers the mobile-clinic nights** | A former colleague describes Maya as calm during an outbreak. Inspect reveals that the pilot depended on a one-time grant. | Candidate profile and performance record |
| 3 | Campaign advertisement | **"Care in every district" dominates the airwaves** | Maya promises longer clinic hours and paid health apprenticeships. Inspect reveals optimistic first-year revenue assumptions and a funding gap. | Platform and independent budget reading |
| 4 | Scandal/investigation | **Medical supplier donations raise contract questions** | A distributor that may bid on city work donated to Maya's campaign. A relationship is established, but an improper award is not proven. | Two-point controversy file |
| 5 | Candidate statement | **Vargas promises an open-contract rule** | Maya answers donor criticism with a proposed public bidding portal. The rule is still a promise and does not remove the donor relationship. | Controversy file and platform |
| 6 | Fact-check alert | **Fact-check: twelve clinics were not built** | Supporters turned two mobile units and partnerships into a false twelve-clinic construction claim. | Original social post and independent fact-check |

The donor card is an example of all three reading depths:

- **Glance:** the headline says medical-supplier donations raise questions.
- **Inspect:** the player learns that the financial relationship is documented,
  no improper award has been proven, and Maya responds that all contracts will
  use published competitive bidding.
- **Deep Dive:** the player may spend two investigation points to open the
  controversy file and review its source and exact wording.

This presentation intentionally avoids reducing the donor issue to a simple
green or red verdict. The player decides how much the relationship, missing
proof, and proposed safeguard matter.

### 2.8 Records tab and the full structured dossier

The Hub's **Records** tab is a gateway rather than another long information
dump. Its first parchment panel briefly explains the archive and provides a
large teal **Open Full Dossier** button.

Below that button are Evidence Connection cards. They explain how two files are
related using labels such as Supports, Corrects, Adds Context, or Exposes
Missing Information. If checking one record unlocks another record for free,
the connection states **Free follow-up unlocked**.

Opening the full archive leads to a separate Dossier screen. This screen again
shows the candidate identity at the top and then uses three folder-like tabs:

#### Overview

The Overview provides:

- biography and public-service background;
- documented strengths;
- visible concerns;
- qualitative experience level;
- number of evidence files and sources;
- number of accountable records; and
- number of unresolved files.

#### Platform

The Platform lists the candidate's three main proposed actions. For Maya these
are:

- extend clinic hours and mobile care;
- create paid public-health apprenticeships; and
- replace the highest-risk water lines.

The interface reminds the player that a platform is a statement of intent and
must be compared against budgets, public records, and implementation history.

#### Evidence

The Evidence tab contains the candidate's nine files. Filter controls separate
them into records, campaign material, public claims, fact-checks, debate,
questions, and bookmarked files.

Every candidate currently has the same evidence-category structure:

- profile;
- platform;
- campaign advertisement;
- public performance record;
- independent budget reading;
- social-media claim;
- independent fact-check;
- controversy; and
- debate answer.

Normal five-candidate elections contain 45 evidence files. The authored
three-candidate fixture retains its original 27 files.

### 2.9 Evidence Reader: checking one source

Evidence opens in a large centered paper reader over a darkened background. It
looks like a physical record placed above the current screen rather than a new
flat application page.

Its visual order is:

1. candidate-colored header showing the evidence category;
2. close button in the upper-right;
3. large evidence title and an **Opened** stamp;
4. source organization in a highlighted strip;
5. short summary in heavier text;
6. complete evidence details;
7. a Source Check panel;
8. a fact-check finding when applicable;
9. evidence-relationship explanations when applicable; and
10. Bookmark and Close buttons at the bottom.

The Source Check panel converts numeric reliability into a broad cue such as
strong, moderate, or weak. Raw reliability numbers are not presented as a
candidate grade. Fact-check files additionally display a finding such as
verified, misleading, missing context, or partially true.

For Maya, example files include:

- **Performance record**, from the Bayhaven Records Office: clinic wait times
  fell in two pilot districts, but the program used a one-time grant;
- **Independent budget reading**, from the Civic Ledger Institute: the
  first-year clinic plan has a funding gap if projected business taxes arrive
  late;
- **Trending claim**, from a HarborTalk user post: Maya supposedly built twelve
  clinics, although records show two mobile units; and
- **Claim review**, from the Bayhaven Fact Desk: her access claims are broadly
  supported, but the construction claim is misleading.

### 2.10 Investigation points and evidence relationships

The investigation allowance is global across all five candidates, not a fresh
allowance for each candidate:

- **Relaxed:** no point limit;
- **Standard:** 12 points; and
- **Limited:** 7 points.

Surface information is free. Profiles, platforms, campaign advertisements, and
social posts cost zero points. Public records, budgets, fact-checks, and debate
answers usually cost one point. Controversy files cost two points. A file only
charges the first time it is opened; reopening it is free.

Evidence is also connected rather than isolated. Maya currently has these
authored relationships:

- the social post leads to a fact-check that corrects it;
- the platform leads to a budget reading that exposes missing funding details;
- the campaign advertisement leads to a public record that adds context; and
- the donor controversy references a public performance record.

Opening the source side of the first three relationships unlocks the target as
a free follow-up. For example, a player who reads Maya's free platform can then
open its linked budget reading without paying the normal one-point cost.

Viewed files, exact point costs, unlocked follow-ups, and bookmarks are saved
automatically in the active city slot.

### 2.11 Debate: shared group-chat investigation

The **Debate** tab is located beside Promises and Records inside every Candidate
Hub. The debate is shared across the election, but the currently selected
candidate is treated as the focus candidate in the chat layout.

Three horizontally scrollable topic chips appear at the top:

- **Unsafe Water After the Floods** - 10 messages;
- **Jobs That Last** - 10 messages; and
- **Clinics, Budgets, and Accountability** - 12 messages.

The selected topic is followed by a dark-blue topic header and then a complete,
scrollable message history. Candidate messages resemble speech bubbles with a
small portrait, candidate-colored border, speaker name, and rhetorical-style
label. Moderator and Record Desk entries are centered and use a neutral color.

Each message may include:

- the statement or rebuttal;
- a public-reaction chip such as Positive, Mixed, Skeptical, or Surprised;
- one or more evidence chips;
- a link to the speaker's Civic Archive biography;
- a related structured promise or past-history trail;
- a neutral Then-vs-Now comparison when the authored record supports one;
- a bookmark control;
- a pin-to-Receipts control; and
- a suspicious-statement flag.

These controls record the player's judgment. Marking something suspicious does
not make it objectively false in the simulation.

In the water topic, the moderator asks what each candidate would do while
families are boiling tap water. Maya answers:

> Mobile testing teams go first. We cannot repair what we have not measured
> street by street.

Her claim links to her platform. After Julian argues for immediate private
operators, Maya replies:

> A private contract still needs inspectors. Fast paperwork does not make
> water safe.

That rebuttal links to Maya's debate-answer file. Later, the neutral Record Desk
summarizes the available public record across all five candidates. This lets
the debate feel dramatic while still returning the player to inspectable
evidence.

### 2.12 Receipts Board: the player's investigation notebook

The Receipts Board is opened from the receipt icon in the Candidate Hub header.
It is a global board for the entire active election, not a separate board for
each candidate.

The upper header contains:

- the **Receipts Board** title;
- active city name;
- back button; and
- candidate-comparison icon.

The first parchment panel reminds the player that the board does not provide a
match score or recommendation. Directly below are horizontally scrollable issue
filters: All Issues plus the active city's problem categories.

The board collects four kinds of player-selected material:

- pinned Pulse claims;
- pinned debate statements;
- pinned unresolved questions; and
- bookmarked evidence files.

If nothing has been saved, a large empty-state panel explains where receipts
can be pinned. Saved receipts display as one column on a phone and two columns
on wider layouts.

Each Receipt card contains:

- a type icon and candidate color;
- candidate/category label;
- claim, question, statement, or evidence title;
- short summary;
- suggested linked evidence or relationship explanations;
- remove control;
- private-note button; and
- an Open Details button when the receipt is an evidence file.

Private notes support up to 180 characters and are stored only with the local
city save.

For example, a Maya-focused board might contain:

- the pinned Pulse claim **"Care in every district" dominates the airwaves**;
- the unresolved question **Where will the clinic expansion budget come from?**;
- Maya's water-testing debate statement;
- the bookmarked **Independent budget reading**; and
- a private note such as "Compare projected tax revenue with the one-time grant
  used in the pilot."

The board suggests relationships, but it does not automatically announce a
correct conclusion.

### 2.13 CityBook, news coverage, and connected sources

The candidate investigation now extends into a small fictional media ecosystem.
This does not replace the quick roster cards, the four Candidate Hub tabs, or
the Evidence Reader. It adds optional paths for players who want more context.

From a Candidate Hub, a compact information strip appears below the candidate
header. **Open CityBook** goes to `/citybook/:candidateId`. A recent-coverage
headline can open `/news/:coverageId`. The component is deliberately slimmer
than the Bio, Promises, Debate, and Records content so fast players can ignore
it without losing the main voting flow.

Every normal generated candidate has a CityBook profile with:

- a wide authored environmental banner and the existing candidate portrait;
- name, handle, short biography, party, and public-attention count;
- Posts, About, and Media tabs;
- four to seven generated posts, depending on information footprint and campaign noise;
- Like, Love, Laugh, Shock, Sad, Angry, and **Resibo?** reaction counts;
- a stable thread of ten post-specific fictional comments per post; and
- optional links to a receipt, debate context, city issue, or related news.

Candidate portraits now use one reusable circular avatar crop with
`BoxFit.cover`, so the dossier's rectangular portrait frame cannot leak into
CityBook. Each comment also stores a deterministic reaction distribution based
on its tone/archetype and the parent post's actual engagement. The comment UI
shows up to three dominant icons plus the total, keeps counts below parent-post
reach, and naturally permits zero-reaction comments. Internal account-archetype
metadata is retained for procedural wording, but labels such as "Recently
created" or "Repeated slogan pattern" are no longer rendered as answers for the
player.

The preserved authored fixture still provides Maya, Julian, and Victor for
stable UI/reference tests. For example, Maya's clinic-expansion post appears as
`cb_maya_clinics`. It makes a candidate-owned public claim, shows a mixed
reaction distribution, and opens a ten-person thread containing supportive,
skeptical, affected-resident, and suspicious-account perspectives. The UI
keeps those reactions visually secondary. Maya's old scale-related post is
marked historical and can open the existing neutral Then-vs-Now card. Its
receipt action opens `maya_publicRecord`, charges or unlocks it through the
existing investigation rules, and displays the public record through the
Transparency Portal treatment.

The Chronicle remains the city feed. Every major issue story can now expose a
**Read Coverage** action. It opens `/news/event/:eventId`, where the player sees
one factual event summary beside three news framings. Each world receives three
deterministically named outlets with different combinations of sensationalism,
depth, speed, tone, editorial aggression, and headline style. These traits
change emphasis and presentation; they do not classify an outlet as simply
true or fake.

Opening one coverage card leads to a full mobile article. The reader shows the
outlet and category, headline, subheadline, byline, fixed 16:9 image placeholder,
quick summary, article body, outlet traits, related issue and candidates,
available receipts, related stories, and a route back to compare all coverage.
The three stories share one underlying event and therefore cannot silently
invent three incompatible versions of city truth.

Evidence Reader sources also have distinct visual presentations. Public records
use a Bayhaven Transparency Portal view; budgets resemble formal documents;
social posts resemble a CityBook embed; campaign material has a poster slot;
and fact-check, debate, investigative, platform, and archive material each have
source-appropriate framing. The complete normalized evidence information still
appears beneath that treatment, preserving the existing deep-reader behavior.

Generic information references and relationships connect city problems,
Chronicle entries, candidate history, promises, debates, CityBook posts, news
events, coverage, and evidence. Current authored and generated media use stable
IDs. Generated posts, comments, reactions, events, headlines, and article text
are created from the versioned seed and one shared candidate truth, then stored
inside the save. Save schema 7 restores the complete election and living-city snapshots instead of
rerolling it; schema-5 saves migrate through the authored fallback.

CityBook banners, selected CityBook and Campaign Trail posts, and all twelve
issue families now resolve to authored artwork. News outlets reuse the image
belonging to their shared underlying event, so a change of framing does not
silently change the pictured event. Unknown future media keys retain an
aspect-ratio-preserving coded fallback.

### 2.14 TV Broadcast reports

Two or three major pre-election `UnderlyingNewsEvent` records in each seeded
city receive a deterministic R-8 television report. The selection is based on
the event's existing public-impact and importance values. Reopening a save does
not reroll the selected reports, and watching one does not advance time, spend
investigation points, change opinion, or mutate the city.

Eligible Chronicle cards expose **Watch Report** beside **Read Coverage**. The
same report can also be opened from the event's coverage-comparison page and
its full news articles. Every route resolves back to the same event ID, issue,
candidate references, evidence references, article IDs, date, factual summary,
impact, and visual key. TV is therefore a presentation of existing truth, not
a second news generator.

The current broadcast presentation includes:

- one original fictional robot reporter, R-8, in a responsive illustrated
  studio;
- the shared issue artwork as the report's picture-in-picture visual;
- a localized lower third and five short English/Filipino dialogue pages;
- player-paced visual-novel controls where a tap, click, Enter, or Space first
  finishes the current typing animation and the next activation advances;
- punctuation-aware typewriter timing with a faster, non-bobbing reduced-motion
  mode;
- an optional low-volume electronic dialogue blip throttled across characters,
  controlled by a persistent Settings switch and safely disabled if audio is
  unavailable; and
- end controls for returning to the Chronicle or opening the matching full
  article.

The broadcast catalog has structured types for major reports and future
community features. The current build intentionally authors only issue-backed
major reports. Extra reporter personalities and humorous community segments
remain optional future additions rather than claims about the present MVP.

### 2.15 Candidate comparison

The comparison icon in the Receipts Board opens a large bottom sheet. The
player selects up to two candidates using chips near the top. Candidates pinned
from their Hub headers are preferred as the initial pair.

Each comparison card shows only public information:

- portrait and public identity;
- opened and bookmarked evidence counts;
- documented strengths; and
- questions to investigate.

Hidden capability values and candidate quality bands are excluded. The sheet
is therefore a side-by-side reading aid, not a scoring system.

### 2.16 Persistence, language, and responsiveness

The following candidate-investigation state persists in the local city save:

- viewed evidence files;
- exact investigation-point charges;
- free follow-up unlocks;
- evidence bookmarks;
- pinned Campaign Trail items;
- pinned unresolved questions;
- debate bookmarks, pins, and suspicious flags;
- pinned candidates for comparison; and
- private Receipt notes.

The save format is currently schema version 10 and includes migration support
for older local runs.

Candidate-interface controls are available in English and Filipino. The
authored fictional record content is currently primarily English, while the
screen titles, navigation, action labels, evidence controls, point labels,
relationship labels, and Receipt tools respond to the selected language.

The layouts have automated coverage at a narrow 390 x 844 phone size and a wide
browser size. Long pages scroll vertically, tab and filter rows scroll
horizontally where appropriate, portraits preserve their aspect ratio, and
missing media uses a stable fallback rather than collapsing the layout.

### 2.17 Fairness and hidden simulation data

The pre-election interface only displays information that a fictional voter is
allowed to see. Internal values such as implementation ability, integrity,
coalition skill, crisis response, budget discipline, corruption risk, and
hidden candidate quality remain in the domain and simulation layers.

Those hidden values affect the city only after the election. The player is not
told whether Maya, Julian, or Victor is the correct choice. A candidate may be
capable but compromised, honest but ineffective, technically strong but poor at
coalition building, or genuinely dangerous while still having public appeal.

## 3. Other Current Game Features

### Main Menu and City Saves

The main menu allows the player to start or continue a city, read the game
instructions, access Settings, and view local city slots. The current system
supports five local save slots with automatic progress saving.

### City Brief, Chronicle, and News

Before voting, the City Brief presents Bayhaven's starting condition, major
problems, issue markers, and city indicators. The City Chronicle adds fictional
news and resident voices. Major entries can open three outlet framings, full
articles, and selected R-8 TV reports drawn from the same underlying event.
These pages provide background information only; the city does not advance and
random term events do not occur before voting.

### Election

The election screen lets the player select a candidate, identify the city issue
that mattered most to the decision, and record their confidence. The game asks
for confirmation before sealing the ballot and then displays an animated winner
reveal.

### Term Simulation

After the election, the chosen candidate becomes the city's leader and the
post-election screen opens on a living illustrated map. The player remains an
observer/voter. The game automatically progresses from Day 0 through Day 365
and displays a fictional date derived from that canonical day. The available
controls are Pause, Day (one day per second), Week (seven days per pulse), Month
(thirty days per pulse), and YEAR. YEAR is a bounded finish-year command rather
than a repeating ninety-day speed: it processes remaining days through the
same engine in logical batches, stops exactly at Day 365, and can resume after
an event pause without skipping or duplicating history.

The old four phases are retained internally as quarters: days 1-91, 92-182,
183-273, and 274-365. They organize project reviews and the final report; they
are no longer manually advanced. Settings persist four Critical Event
Interruption modes. **Auto Open** pauses and opens critical/rare events.
**Pause & Notify**, the default, pauses and shows a notice that the player may
open. **Notify Only** continues while showing the notice. **Never Interrupt**
neither opens nor pauses automatically. Every mode still records the event and
its marker/media consequences.

Each ordinary term also contains eight deterministic fictional World
Conditions distributed through the year. Weather, economic, utility,
logistics, health, school, holiday, and festival conditions have saved start
days, durations, intensities, and a `natural` source. While active they modify
event-template weights and project progress; they do not directly schedule a
flood, crisis, or success. The simulation header shows the strongest current
condition and its remaining days. A developer-level injector can add a
condition tagged `sandbox`, and that source survives persistence. There is not
yet a public Sandbox controls screen.

The map is the primary simulation UI. It uses a dedicated 90-degree overhead
Bayhaven illustration rather than the older waterfront skyline. Its expanded
city footprint extends the river, roads, neighborhoods, commercial blocks,
parks, institutional areas, government services, and industrial outskirts
around the central civic area, so the initial camera shows only part of the city
and meaningful panning is required to explore it. Roads, bridges, districts,
roofs, and landmark geography remain readable like a fictional navigation map.
Touch/mouse pan, pinch/wheel zoom, and custom game-styled zoom controls operate
on one square raster.

Twenty-seven centralized normalized anchors cover civic, health, education,
market, transport, media, sanitation, residential, commercial, public-safety,
emergency, utility, park, industrial, logistics, road, and recreation uses.
Nineteen of these are localized permanent tap targets distributed across the
whole city, including City Hall, hospital, university, schools, market, mall,
police headquarters, fire/disaster center, water works, waste center, news
headquarters, terminal, Riverside, sports area, industry, and logistics.
Labels stay compact and mostly appear only at closer zoom levels.

Temporary event markers use deterministic weighted placement: their issue,
event category, and authored preferred locations direct them toward sensible
facilities before a district fallback is used. A stable radial spread keeps
multiple pins from sitting directly on each other or hiding permanent
landmarks. Pins remain attached to the map during pan and zoom, counter-scale to
stay visually small, and retain a 48-by-48 mobile tap target. Marker lifetime
still depends on event importance. Ambient stories usually receive no marker,
while critical markers remain longer. Opening a temporary pin marks it as
inspected and removes it from the map, but never deletes the event: the full
record remains available in Event History, Chronicle, and related media views.
Reduced Motion disables marker pulsing without removing information.

City Hall is permanently tappable. Its overlay shows the elected mayor, broad
public trust and budget health, overall city condition, and every promise-based
project's progress and current stage. Projects receive one independently seeded
review in each quarter. Policy knowledge, implementation, coalition ability,
budget discipline, experience, project difficulty, fiscal room, corruption
risk, and random variation influence progress. The player does not allocate
money or control the mayor directly.

The event engine processes lightweight daily state. A day roll filters and
weights templates using active issues, severity/trend, indicator thresholds,
current projects, budget, trust, corruption pressure, candidate attributes,
quarter, recent event categories, issue/location/template cooldowns, pending
follow-up hooks, and isolated derived seeds. It covers issue-driven,
indicator-driven, administration, external, positive, political, everyday city
life, and genuinely rare events. Positive conditions can create good events;
neutral stories such as the City Hall cat or a viral tricycle can enter history
without moving any statistic.

Causal hooks create delayed event chains. Implemented examples include heavy
rain leading to flooding and possible water/health consequences, roadworks
leading to congestion and business complaints, and the existing flood cleanup,
water repair, clinic recovery, employment recovery, road response, and audit
follow-ups. Every follow-up stores its source event ID. Cooldowns prevent the
same issue, template, chain, or location from dominating the feed.

The full chronological Event History is opened from a separate button instead
of occupying map space. It supports All, Major, Projects, and Community filters.
Opening a marker shows location, date, factual summary, explanation, effects,
chain context, reusable artwork where available, and only the Chronicle, News,
TV, or Project actions that actually exist.

The complete generated year is saved once. The current day gates what the
player can see, so future events do not leak into Chronicle, News, TV, or
CityBook. All later presentations use the same event ID and factual source.
Reloading restores the date, selected speed, pause state, inspected markers,
projects, indicators, issues, event chains, media links, and full generated
history without rerolling past events. The same initial world, elected
candidate, and generation version reproduce the same year; different seeds
produce different timing and histories.

### Term Report

The final report summarizes the administration's strongest gains, hardest
setbacks, indicator changes, major events, and the context of the player's
decision. It explains consequences without declaring that the player's vote was
morally right or wrong.

### Public City Gallery API

Community identity is deliberately separate from normal play. Creating cities,
investigating, voting, simulating, and saving locally never asks for a name. On
the first Visit Cities open or publish attempt, a parchment game dialog asks
only what other players should call the user. The validated 3–24 character name
is stored in `player_profiles`; `supabase_flutter` silently creates and persists
the anonymous Auth session that supplies the stable owner ID. No UUID, email,
password, phone, avatar, biography, presence, or social graph appears in UI.

A completed Term Report can publish its sanitized `PublicCitySnapshot` as
Public or Private. The builder copies only city, term, starting pressure, top
issue, elected candidate/party, final condition, short summary, major issues,
major events, creation date, and privacy. It cannot serialize the world seed,
save file, hidden candidate capabilities, investigation history, or private
notes. The database assigns ownership from `auth.uid()` rather than accepting
an owner field in the city POST body.

Database access remains explicit and screenshot-friendly in Flutter's `http`
service: GET retrieves public cities, owned cities, profiles, search results,
and one player's public cities; POST creates profiles and snapshots; PATCH
changes only privacy; DELETE removes only an owned uploaded snapshot. JSON is
encoded/decoded directly. Every request carries the authenticated user token so
RLS can enforce ownership.

Visit Cities now contains a debounced server-side player search plus **Explore**
and **My Cities**. Explore explicitly requests `is_public=eq.true` and cards show
the owner's display name. Selecting a player opens only that player's public
cities. My Cities returns both privacy states and provides View, Make Public /
Make Private, and confirmed Delete Snapshot actions. Deleting remotely never
deletes the local city save.

The last successful public and owned lists are cached separately; cached owned
rows are accepted only when their owner matches the current authenticated
session. Offline reads may remain visible, but publish/privacy/delete never
pretend to succeed without a connection. Duplicate names, auth/RLS denial,
deleted rows, timeouts, malformed JSON, unavailable configuration, and server
failure map to short safe UI states. Configuration still uses client-safe
`SUPABASE_URL` and `SUPABASE_ANON_KEY` values; service-role credentials and
database passwords are rejected and do not belong in the app.

### Settings and Accessibility

The app currently supports English and Filipino. It also includes persistent
settings for reduced motion, high-contrast presentation, dialogue sounds, UI
sound effects, SFX volume, optional background music, music volume, and the four
Critical Event Interruption behaviors described above.

### Shared Audio System

All short interface effects now pass through a centralized `GameAudioService`
rather than creating a player for each widget. A small pool of low-latency
players preloads and safely overlaps the cohesive CC0 effect vocabulary while a
short throttle prevents rapid duplicate taps from creating excessive playback.
Mappings cover general navigation, documents and receipts, bookmarks, social
threads, ballot selection/submission, and normal, positive, negative, or
critical simulation developments. Disabling Sound Effects immediately silences
this layer; the separate Dialogue Sounds switch continues to control the R-8
typewriter blip.

The same service has three route-aware music contexts: menu, investigation, and
simulation. It supports looping, fade transitions, persistent enable/volume
settings, app lifecycle pause/resume, and temporary volume ducking during TV
reports. Local music files are currently present at the three expected paths,
but their redistribution licenses are not recorded and must be confirmed or
replaced before a public release. Asset probing still makes missing optional
tracks a safe no-op, and moving among Candidate Hub tabs or related
investigation pages does not restart one context repeatedly.

## 4. Current Scope and Limitations

The current version is an offline one-term MVP. It already demonstrates the
complete investigation-to-consequence loop, but the following features remain
planned for later development:

- multiple connected election cycles;
- expansion of the procedural candidate content libraries and anti-repetition history;
- long-term candidate and administration history;
- laws and expanded promise tracking;
- final voter-behavior profiles;
- final art for every Pulse and evidence-media slot;
- Firebase authentication and cloud saves;
- richer comparisons and moderation for public city sharing; and
- runtime AI-generated narrative variation.

At present, the strongest and most complete portion of the project is the local
Candidate Roster, Candidate Hub, Pulse, Debate, CityBook, comparative news,
Dossier, source-specific Evidence Reader, and Receipts Board experience
connected to a deterministic one-term city simulation.
