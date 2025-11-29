
import Image


struct SettingsView: View {
    @StateObject var vm = SettingsViewModel()
   
    var body: some View {
        List(vm.settings) { item in
            HStack {
                if let icon = item.icon {
                    Image(systemName: icon)
                }
               
                Text(item.title)
               
                Spacer()
               
                switch item.type {
                case .detail(let value):
                    Text(value)
                        .foregroundStyle(.gray)
                   
                case .toggle(let isOn):
                    Toggle("", isOn: .constant(isOn))
                        .labelsHidden()
                   
                case .navigation:
                    Image(systemName: "chevron.right")
                }
            }
        }
        .onAppear {
            vm.loadProfile()
            vm.buildSettings()
        }
    }
}
