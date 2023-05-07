//
//  NewWidget.swift
//  NewWidget
//
//  Created by Luis Enrique Rosas Espinoza on 05/05/23.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), widgetData: Array(repeating: JsonData(id: 0, email: "", name: ""), count: 2))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date(), widgetData: Array(repeating: JsonData(id: 0, email: "", name: ""), count: 2)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getJson { (modelData) in
            let data = SimpleEntry(date: Date(), widgetData: modelData)
            guard let update = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) else { return }
            let timeline = Timeline(entries: [data], policy: .after(update))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    var widgetData: [JsonData]
}

struct JsonData: Decodable {
    var id: Int
    var email: String
    var name: String
}

func getJson(completion: @escaping ([JsonData]) -> ()) {
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/comments?postId=1") else { return }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data else { return }
        
        do {
            let json = try JSONDecoder().decode([JsonData].self, from: data)
            DispatchQueue.main.async {
                completion(json)
            }
        } catch let error as NSError {
            print("Error", error.localizedDescription)
        }
    }.resume()
}

struct NewWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            VStack {
                Text("My List")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.vertical, 8)
                    .frame(maxWidth: Double.infinity)
                    .background(.blue)
                Spacer()
                Text(String(entry.widgetData.count))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                    
            }
        case .systemMedium:
            VStack {
                Text("My List")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.vertical, 8)
                    .frame(maxWidth: Double.infinity)
                    .background(.blue)
                Spacer()
                Text(String(entry.widgetData[0].name))
                    .fontWeight(.bold)
                Text(String(entry.widgetData[0].email))
                Text(String(entry.widgetData[1].name))
                    .fontWeight(.bold)
                Text(String(entry.widgetData[1].email))
                Spacer()
                    
            }
        default:
            VStack {
                Text("Users:")
                    .fontWeight(.bold)
                ForEach(entry.widgetData, id:\.id) { item in
                    Text(item.name)
                        .fontWeight(.bold)
                    Text(item.email)
                }
            }
        }
        
    }
}

struct NewWidget: Widget {
    let kind: String = "NewWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NewWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemLarge, .systemMedium, .systemSmall])
    }
}

struct NewWidget_Previews: PreviewProvider {
    static var previews: some View {
        NewWidgetEntryView(entry: SimpleEntry(date: Date(), widgetData: Array(repeating: JsonData(id: 0, email: "", name: ""), count: 2)))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
