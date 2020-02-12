//
//  ImagePickerTestView.swift
//  InstaPost
//
//  Created by Saumil Shah on 11/19/19.
//  Copyright © 2019 Saumil Shah. All rights reserved.
//

import SwiftUI

struct ImagePickerView: View {
    
    @State var showImagePicker: Bool = false
    @Binding var image: Image?
    @Binding var base64ImageData: Data?
    
    var body: some View {
        
        VStack(spacing: 2) {
            
            CustomImageView(image: self.$image)
                .onTapGesture {
                    withAnimation { self.showImagePicker.toggle() }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                
                if self.image == nil {
                    
                    Button(action: { withAnimation { self.showImagePicker.toggle() } }) {
                        
                        HStack(alignment: .center, spacing: 1) {
                            Text("Choose from Gallery")
                            getSystemImage("photo.fill", .accentColor, .body)
                        }
                    }
                    
                } else {
                    
                    Button(action: { withAnimation { self.image = nil; self.base64ImageData = nil } }) {
                        
                        HStack(alignment: .center, spacing: 0) {
                            
                            Text("Remove Photo").foregroundColor(.red).padding(.horizontal)
                            getSystemImage("minus.circle.fill", .red, .callout)
                        }
                    }
                }
                
            }
        }
        .padding(4)
        .accentColor(.pink)
        .sheet(isPresented: self.$showImagePicker) {
            OpenGallary(isShown: self.$showImagePicker, image: self.$image, base64ImageData: self.$base64ImageData)
                .accentColor(.pink)
        }
        
    }
}

struct ImagePickerView_Previews : PreviewProvider {
    static var previews: some View {
//        ImagePickerView(image: .constant(nil), base64ImageData: .constant(nil))
        ImagePickerView(image: .constant(Image(systemName: "photo")), base64ImageData: .constant(nil))
            .previewDevice("iPhone XS")
    }
}

struct CustomImageView: View {
    
    @Binding var image: Image?
    
    var body: some View {
        
        Group {
            
            if self.image == Image(systemName: "xmark.rectangle") {
                
                Text("No Image Found or taking too long to load").font(.system(size: 14)).foregroundColor(.gray).bold().padding()
                
            } else {
                
                self.image?.resizable()
                    .font(.system(size: 10, weight: .ultraLight))
                    .aspectRatio(contentMode: .fit)
                    .frame(
//                    .frame(width: UIScreen.main.bounds.width,
//                                                      height: 250,
                        alignment: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.clear, lineWidth: 2))
                        .shadow(color: Color(Color.RGBColorSpace.sRGB, white: .zero, opacity: 0.4), radius: 4)
            }
        }
    }
}

struct OpenGallary: UIViewControllerRepresentable {
    
    let isShown: Binding<Bool>
    let image: Binding<Image?>
    let base64ImageData: Binding<Data?>
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        let isShown: Binding<Bool>
        let image: Binding<Image?>
        let base64ImageData: Binding<Data?>
        
        init(isShown: Binding<Bool>, image: Binding<Image?>, base64ImageData: Binding<Data?>) {
            self.isShown = isShown
            self.image = image
            self.base64ImageData = base64ImageData
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            self.image.wrappedValue = Image(uiImage: uiImage)
            self.isShown.wrappedValue = false
            
            DispatchQueue.main.async {
                
                
                if let validBase64Data: Data = uiImage.pngData()?.base64EncodedData() {
                    //                self.base64ImageString.wrappedValue = String(data: validBase64Data, encoding: .utf8)
                    self.base64ImageData.wrappedValue = validBase64Data
                    print("Base64 Encoding Successful.")
                    
                } else {
                    print("Couldn't convert to a validBase64Data.")
                }
                
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isShown.wrappedValue = false
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isShown: isShown, image: image, base64ImageData: base64ImageData)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<OpenGallary>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<OpenGallary>) {
        
    }
    
}
