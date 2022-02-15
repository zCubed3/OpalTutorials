//
// Super simple unlit shader
//

//
// Since this is in the "SuperEasy" category, expect comments on basically everything!
// 

// Defines a shader in ShaderLab, we normally don't touch this and Unity sets it up for us
// If you change the name it will change the name of the shader inside the material menu!
Shader "Opal/SimpleUnlit"
{
    // Properties we can give the shader that will show up on materials
    // This could be a texture, number, toggle, or more!
    Properties
    {
        // We have only one actual property, this is a texture input!
        // In shaderlab defining a property is always "NAME ("NAME IN EDITOR", TYPE) = INITIALIZER"
        // So... following this rule we can have properties like
        //
        // _Texture ("My Texture", 2D) = "white" {}, the type "2D" says this is a 2D texture, not any other type of texture!
        // Valid initializer values for textures are "white", "black", "gray", or "bump"
        // This provides the texture input with a default to go off of when we don't have anything
        //
        // Other valid texture types are "Cube", "CubeArray", "2D", "2DArray", and "3D"
        // Although most of the time you'll only be using "Cube" and "2D"!
        //
        // The documentation for these parameters is here, https://docs.unity3d.com/Manual/SL-Properties.html
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader // You can ignore this block, in most cases you won't be making multiple subshaders unless you're targeting specific hardware!
    {
        // SubShader tags, there are a lot of these so I recommend looking at, https://docs.unity3d.com/Manual/SL-SubShaderTags.html
        //
        // The main values you're gonna have to worry about here are "RenderType" and "Queue"
        // "RenderType" = Tells Unity how to render this shader, either as Opaque, Transparent, etc...
        // "Queue" = Tells Unity when to render this shader, Opaque comes first, Transparent comes later!
        Tags { "RenderType"="Opaque" }
        
        LOD 100 // Used mostly on mobile platforms for optimizing shaders, you can ignore this most of the time as well!

        Pass
        {
            // While you won't be touching them too often for simpler shaders...
            // Passes can have tags too! https://docs.unity3d.com/Manual/SL-PassTags.html

            // You can name passes! This isn't too useful unless you're using a custom render pipeline or are making a post processing shader!
            Name "Unlit"

            // This is the start of a shader program's block of code for HLSL!
            // You might see "CGPROGRAM" sometimes, under the hood Unity treats CGPROGRAM as HLSLPROGRAM now, so they're the same!
            HLSLPROGRAM

            // #pragma is a shader keyword for special actions
            // Unity uses these for many things, but below these are used to...

            // Tells Unity what function is the vertex function, we'll explain below what that is! 
            #pragma vertex vert

            // Tells Unity what function is the fragment function, we'll explain below what that is!
            #pragma fragment frag

            // #include is familiar to C users!
            // But for anyone who hasn't used C, it literally includes another source file into this one for use
            // In this case we're including "UnityCG.cginc" which is a very helpful library file for working with Unity, without it things might be difficult!
            #include "UnityCG.cginc"

            // Again another familiar thing for C users, structs!
            // In HLSL structs are decorated with "Semantics"
            // These are a fancy way of telling the GPU what value this represents in memory
            //
            // EX: POSITION = Vertex Position for this vertice
            // EX: TEXCOORD0 = UV Coordinate for this vertice

            // Think of the appdata struct as your program arguments
            // These are values you need use when executing the program that need to be present from the start
            // Since appdata is first passed to the vertex function, this is data that describes a vertex! 
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            // Think of v2f as an intermediate struct for the more complex fragment program
            // appdata operates per vertex, but v2f operates per fragment
            // If you're not familiar with the term, a fragment is a pixel in GPU terms!
            // These are values we access per pixel (Values that need precision)
            // Since a GPU is a fancy interpolation engine, the values within this are interpolated across a triangle!
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            // Samplers are the GPU terminology for textures, they're objects that encapsulate the texture data for faster computation
            // A sampler2D is a texture sampler for a 2D texture

            // With Shaderlab, we define a variable of the same type and name as the one defined in the Properties block
            // We can now access that value inside our shader
            // The variable below is the sampler for _MainTex declared up above in our parameters
            uniform sampler2D _MainTex;

            // The Vertex program
            // This is a program that executes per vertex on a model
            // Since data is very imprecise here, we mostly use the vert function to setup our values that are sent to the fragment program
            
            // You can think of a vertex program as a sketch
            // This function here takes in an "appdata" struct and returns a "v2f" struct
            v2f vert (appdata v)
            {
                // Remember, v2f is an intermediate for holding data that will be interpolated over a triangle!
                v2f o;

                // To keep it simple, GPUs have a type of "space" known as "clip" space
                // Clip space is what we see on the screen, it is a 2D representation of the 3D world!
                // In order to see anything we need to translate these 3D coordinates to their 2D "screen space" representations!
                // The built in Unity helper function "UnityObjectToClipPos" will translate our vertex into clip space for us 
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                // Since we want to sample a texture in our fragment, we need texture coordinates, we can simply just assign these for later usage!
                o.uv = v.uv;

                return o;
            }

            // The Fragment program
            // This is a program that executes per pixel that makes up a given polygon!
            // Data is very precise here, but since you're computing per pixel, if you are doing expensive math it can get slow fast!
            // Consider moving expensive computation to the vertex shader if the data is deterministic and can be interpolated!

            // You can think of a fragment program as a finished drawing, with color and all!
            // This function takes in our "v2f" struct and returns a "fixed4", which is another name for an RGBA color!
            fixed4 frag (v2f i) : SV_Target // You can ignore the semantic here, it is only important for niche cases!
            {
                // This function is a lot simpler than the vertex shader since all it does is sample the texture and return the color!
                // tex2D() is a function that takes a sampler2D and a 2D vector representing texture coordinates
                // The value returned is a sample of the texture data, either with or without filtering!
                return tex2D(_MainTex, i.uv);
            }

            // The end of this shader program block, without this your shader will error and turn pink!
            // You might see "ENDCG" sometimes! It's the same case as above as to why you'll see it!
            ENDHLSL
        }
    }
}
