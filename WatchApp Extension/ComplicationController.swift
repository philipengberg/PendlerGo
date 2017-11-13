//
//  ComplicationController.swift
//  WatchApp Extension
//
//  Created by Philip Engberg on 22/07/2017.
//
//

import ClockKit
import RxSwift

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    private let viewModel = ComplicationViewModel(locationType: .home)
    private let bag = DisposeBag()
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(Date())
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
//        viewModel.departures.asObservable().shareReplay(1).subscribe(onNext: { (departures) in
//            guard let lastDeparture = departures.last else { handler(nil); return; }
//            print("Last: \(lastDeparture.combinedDepartureDateTime)")
            handler(viewModel.departures.last?.combinedDepartureDateTime)
//        }).addDisposableTo(bag)
//        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        
//        print("Waiting for data")
//        viewModel.departures.asObservable().shareReplay(1).subscribe(onNext: { [weak self] (departures) in
//            print("Looking for first")
            handler(makeTimelineEntry(from: Date(), for: complication.family))
//        }).addDisposableTo(bag)
        
//        switch complication.family {
//        case .utilitarianLarge:
//            let template = CLKComplicationTemplateUtilitarianLargeFlat()
//            template.textProvider = CLKSimpleTextProvider(text: "15:59")
//            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
//            
//        case .modularLarge:
//            print("Waiting for data")
//            viewModel.departures.asObservable().shareReplay(1).subscribe(onNext: { [weak self] (departures) in
//                print("Looking for first")
//                guard let departure = self?.viewModel.getFirstDeparture(after: Date()) else { handler(nil); return }
//                print("Found first")
//                let template = CLKComplicationTemplateModularLargeStandardBody()
//                template.headerTextProvider = CLKSimpleTextProvider(text: "👉 \(departure.finalStop)")
//                template.body1TextProvider = CLKSimpleTextProvider(text: departure.time)
//                // CANCELLED
//                if departure.cancelled {
//                    template.body2TextProvider = CLKSimpleTextProvider(text: "AFLYST")
//                } else if departure.isDelayed {
//                    template.body1TextProvider = CLKSimpleTextProvider(text: departure.realTime)
//                    template.body2TextProvider = CLKSimpleTextProvider(text: "Forsinket")
//                } else {
//                    template.body2TextProvider = CLKSimpleTextProvider(text: departure.name)
//                }
//                
//                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
//            }).addDisposableTo(bag)
//        default:
//            handler(nil)
//        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        print("After: \(date)")
        var entries = [CLKComplicationTimelineEntry]()
        for departure in viewModel.getAllDepartures(after: date) {
            print("Making future")
            guard let template = makeTemplate(from: departure, for: complication.family) else { print("Got no template 3"); continue }
            entries.append(CLKComplicationTimelineEntry(date: departure.combinedDepartureDateTime, complicationTemplate: template))
        }
        print("Entries: \(entries.count)")
        handler(entries)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        switch complication.family {
        case .modularLarge:
            
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "👉 København H")
            template.body1TextProvider = CLKSimpleTextProvider(text: "15:29")
            template.body2TextProvider = CLKSimpleTextProvider(text: "IC 829")
            handler(template)
            
        default:
            handler(nil)
        }
    }
    
    func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void) {
        handler(Date(timeIntervalSinceNow: 60))
    }
    
    // MARK - Utility
    
    func makeTimelineEntry(from date: Date, for complicationFamily: CLKComplicationFamily) -> CLKComplicationTimelineEntry? {
        guard let departure = viewModel.getFirstDeparture(after: date) else { print("Got no template 1"); return nil }
        guard let template = makeTemplate(from: departure, for: complicationFamily) else { print("Got no template 2"); return nil }
        print("We've got a template")
        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
    }
    
    func makeTemplate(from departure: Departure, for complicationFamily: CLKComplicationFamily) -> CLKComplicationTemplate? {
        switch complicationFamily {
        case .modularLarge:
            print("Making template")
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "👉 \(departure.finalStop)")
            template.body1TextProvider = CLKSimpleTextProvider(text: departure.time)
            
            if departure.cancelled {
                template.body2TextProvider = CLKSimpleTextProvider(text: "AFLYST")
            } else if departure.isDelayed {
                template.body1TextProvider = CLKSimpleTextProvider(text: departure.realTime)
                template.body2TextProvider = CLKSimpleTextProvider(text: "Forsinket")
            } else {
                template.body2TextProvider = CLKSimpleTextProvider(text: departure.name)
            }
            
            return template
        default:
                return nil
        }
    }
    
}
